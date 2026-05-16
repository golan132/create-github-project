import { execa } from 'execa';
import fse from 'fs-extra';
import path from 'path';
import { ScaffoldContext } from '../types/scaffold-context.js';
import { Logger } from '../utils/logger.js';

export class DependencyManager {
  async installStandardStack(context: ScaffoldContext): Promise<void> {
    await Logger.info('Installing Standard Enterprise Stack...');

    // Core/Backend Dependencies (Always installed as Shared Libs need them)
    // Note: lodash/fp is included in lodash
    const coreDeps = [
      'class-validator',
      'class-transformer',
      'lodash'
    ];

    const devDeps = [
      '@types/lodash'
    ];

    // NestJS resource-driven dependencies — mirror telepoly / oasis-portal-t setups.
    if (context.apps.nest) {
      await Logger.info('Adding NestJS resource dependencies...');
      coreDeps.push('@nestjs/config', 'reflect-metadata', 'rxjs');

      if (context.backend.swagger) coreDeps.push('@nestjs/swagger', 'express-basic-auth');
      if (context.backend.helmet) coreDeps.push('helmet');
      if (context.backend.pino) coreDeps.push('nestjs-pino', 'pino-http', 'pino-pretty');
      if (context.backend.schedule) coreDeps.push('@nestjs/schedule');
      if (context.backend.eventEmitter) coreDeps.push('@nestjs/event-emitter');
      if (context.backend.telegram) {
        coreDeps.push('teleproto', 'node-telegram-bot-api', 'big-integer');
        devDeps.push('@types/node-telegram-bot-api');
      }
      if (context.backend.drizzle) {
        coreDeps.push('drizzle-orm', 'pg');
        devDeps.push('drizzle-kit', '@types/pg');
      }
    }

    // Frontend Dependencies
    if (context.apps.react) {
      await Logger.info('Adding Frontend dependencies...');
      coreDeps.push(
        '@tanstack/react-query',
        '@mui/material',
        '@emotion/react',
        '@emotion/styled'
      );
    }

    // NOTE: We deliberately do NOT pin react / react-dom / react-native here
    // for mobile apps. Expo bundles its own compatible set per SDK release;
    // manual pinning routinely breaks with new SDKs. Version alignment is
    // handled post-generation by `npx expo install --fix` inside the mobile
    // app directory (see NxWorkspaceGenerator.generateMobile).

    try {
      // Install Prod Deps
      if (coreDeps.length > 0) {
        await Logger.debug(`Running: npm install ${coreDeps.join(' ')}`);
        // Use --no-audit --no-fund --loglevel=error to reduce noise from deprecated transitive deps
        await execa('npm', ['install', ...coreDeps, '--no-audit', '--no-fund', '--loglevel=error'], {
          cwd: context.targetDirectory,
          stdio: 'inherit',
        });
      }

      // Install Dev Deps
      if (devDeps.length > 0) {
        await Logger.debug(`Running: npm install -D ${devDeps.join(' ')}`);
        // Use --no-audit --no-fund --loglevel=error to reduce noise from deprecated transitive deps
        await execa('npm', ['install', '-D', ...devDeps, '--no-audit', '--no-fund', '--loglevel=error'], {
          cwd: context.targetDirectory,
          stdio: 'inherit',
        });
      }

      await Logger.success('Standard Stack dependencies installed.');

      // Now that node_modules is fully populated, ask Expo to align
      // react / react-native / expo-* versions to whatever the installed
      // SDK expects. Doing this earlier (e.g. right after the @nx/expo
      // generator) fails because the new package.json entries (jest-expo,
      // etc.) haven't been installed yet.
      if (context.apps.mobile) {
        await this.alignExpoVersions(context);
      }
    } catch (error) {
      await Logger.error(`Failed to install dependencies: ${(error as Error).message}`);
      throw error;
    }
  }

  private async alignExpoVersions(context: ScaffoldContext): Promise<void> {
    const mobileDir = path.join(
      context.targetDirectory,
      'apps',
      'mobile',
      `${context.projectName}-mobile`,
    );
    if (!(await fse.pathExists(mobileDir))) return;

    // The Nx Expo generator writes a per-app package.json listing
    // jest-expo, expo-status-bar, etc. Workspace-root `npm install` does
    // NOT populate the per-app `node_modules`, so when `expo install --fix`
    // runs from the mobile dir it complains that those deps "aren't
    // installed". A local `npm install` inside the mobile dir reconciles
    // both lists before we ask Expo to align versions.
    try {
      await Logger.info('Installing per-app dependencies for the mobile project...');
      await execa(
        'npm',
        ['install', '--no-audit', '--no-fund', '--loglevel=error'],
        { cwd: mobileDir, stdio: 'inherit' },
      );
    } catch (err) {
      await Logger.warn(
        `Per-app mobile install failed: ${(err as Error).message}. ` +
          'Skipping `expo install --fix`.',
      );
      return;
    }

    try {
      await Logger.info('Aligning Expo dependency versions (`expo install --fix`)...');
      await execa('npx', ['expo', 'install', '--fix'], {
        cwd: mobileDir,
        stdio: 'inherit',
      });
      await Logger.success('Expo versions aligned.');
    } catch (err) {
      await Logger.warn(
        `\`expo install --fix\` failed: ${(err as Error).message}. ` +
          'You can run it manually with `npm run mobile:install`.',
      );
    }

    // Add browser support: react-native-web + react-dom + @expo/metro-runtime
    // are required for `expo start --web` / `nx run <app>:run-web` to work.
    // These are not added by the Nx Expo generator by default.
    try {
      await Logger.info('Adding web support packages (react-native-web, react-dom, @expo/metro-runtime)...');
      await execa(
        'npx',
        ['expo', 'install', 'react-native-web', 'react-dom', '@expo/metro-runtime'],
        { cwd: mobileDir, stdio: 'inherit' },
      );
      await Logger.success('Mobile app web support enabled.');
    } catch (err) {
      await Logger.warn(`Adding web packages failed: ${(err as Error).message}`);
    }

    // Patch app.json: drop the deprecated `android.edgeToEdgeEnabled` flag.
    // Expo SDK 55+ makes edge-to-edge always-on and warns on every build
    // when the key is present.
    await this.patchAppJson(mobileDir);
  }

  private async patchAppJson(mobileDir: string): Promise<void> {
    const appJsonPath = path.join(mobileDir, 'app.json');
    if (!(await fse.pathExists(appJsonPath))) return;

    try {
      const appJson = (await fse.readJson(appJsonPath)) as {
        expo?: { android?: Record<string, unknown> };
      };
      const android = appJson.expo?.android;
      if (android && 'edgeToEdgeEnabled' in android) {
        delete android['edgeToEdgeEnabled'];
        await fse.writeJson(appJsonPath, appJson, { spaces: 2 });
        await Logger.debug('Removed deprecated android.edgeToEdgeEnabled from app.json.');
      }
    } catch (err) {
      await Logger.warn(`Could not patch app.json: ${(err as Error).message}`);
    }
  }

  async addConvenienceScripts(context: ScaffoldContext): Promise<void> {
    await Logger.info('Configuring convenience scripts...');

    const packageJsonPath = path.join(context.targetDirectory, 'package.json');

    if (await fse.pathExists(packageJsonPath)) {
      const pkg = await fse.readJson(packageJsonPath);

      pkg.scripts = pkg.scripts || {};
      pkg.scripts['format'] = 'nx format:write';
      pkg.scripts['format:check'] = 'nx format:check';
      pkg.scripts['build'] = 'nx run-many --target=build --all';
      pkg.scripts['build:all'] = 'nx run-many --target=build --all';
      pkg.scripts['test'] = 'nx run-many --target=test --all';
      pkg.scripts['test:all'] = 'nx run-many --target=test --all';

      if (context.apps.nest) {
        const svc = `${context.projectName}-service`;
        pkg.scripts['serve'] = `nx serve ${svc}`;
        pkg.scripts[`test:${context.projectName}`] = `nx test ${svc}`;
        pkg.scripts['dev'] = `npx nx build ${svc} && node dist/apps/backend/${svc}/main.js`;
        pkg.scripts['dev:watch'] =
          `npx nx build ${svc} --watch & node --watch dist/apps/backend/${svc}/main.js`;
      }

      if (context.apps.mobile) {
        const mobile = `${context.projectName}-mobile`;
        // Metro dev server (use this for QR / Expo Go / web).
        pkg.scripts['mobile:start'] = `nx start ${mobile}`;
        // Browser preview — opens the app in the default web browser.
        // Requires react-native-web + react-dom + @expo/metro-runtime
        // (installed automatically by alignExpoVersions).
        pkg.scripts['mobile:web'] = `nx start ${mobile} --web`;
        // run-android builds the APK and installs on the running emulator
        // / connected device. This is the reliable, non-interactive flow
        // (no need to press "a" in the Metro UI, which doesn't always
        // forward stdin correctly through nx start).
        //
        // `mobile:android-preflight` runs FIRST to:
        //   - kill any stale `adb.exe` (a v32 daemon spawned by Xiaomi /
        //     Samsung / BlueStacks / older Android Studio installs causes
        //     `adb server version (32) doesn't match this client (41)`),
        //   - restart the daemon from $ANDROID_HOME/platform-tools so the
        //     right binary owns port 5037,
        //   - delete stale `*.lock` files under ~/.android/avd/*.avd/
        //     that block emulator launches with `Running multiple
        //     emulators with the same AVD`.
        // Without this, the FIRST `expo run:android` after a reboot
        // often fails with `device offline` / `protocol fault`.
        pkg.scripts['mobile:android-preflight'] =
          'node tools/scripts/android-preflight.mjs';
        pkg.scripts['mobile:android'] =
          `npm run mobile:android-preflight && nx run ${mobile}:run-android`;
        pkg.scripts['mobile:ios'] = `nx run ${mobile}:run-ios`;
        // Generate the native android/ + ios/ folders. Run this once,
        // then `mobile:android-sdk` to drop a local.properties so Gradle
        // finds the SDK without needing ANDROID_HOME in the current
        // shell.
        pkg.scripts['mobile:prebuild'] = `nx prebuild ${mobile}`;
        pkg.scripts['mobile:android-sdk'] =
          `node tools/scripts/write-android-local-properties.mjs ${mobile}`;
        // Per-app install + Expo SDK alignment (re-run after upgrading).
        pkg.scripts['mobile:install'] =
          `cd apps/mobile/${mobile} && npm install && npx expo install --fix`;
      }

      await fse.writeJson(packageJsonPath, pkg, { spaces: 2 });
      await Logger.success('Convenience scripts added to package.json');
    } else {
      await Logger.warn('package.json not found, skipping script injection.');
    }
  }
}
