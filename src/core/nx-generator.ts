import { execa } from 'execa';
import fse from 'fs-extra';
import * as path from 'path';
import { ScaffoldContext } from '../types/scaffold-context.js';
import { Logger } from '../utils/logger.js';

export class NxWorkspaceGenerator {
  public async initWorkspace(context: ScaffoldContext): Promise<void> {
    await Logger.info(`Initializing Nx Workspace: ${context.projectName}`);

    try {
      // 1. Create Workspace
      const args = [
        'create-nx-workspace',
        context.projectName,
        '--preset=apps',
        '--nxCloud=skip',
        '--packageManager=npm',
        '--skipGit=true',
      ];

      await Logger.debug(`Executing: npx ${args.join(' ')}`);

      // Ensure the parent directory exists
      const parentDir = path.dirname(context.targetDirectory);
      await fse.ensureDir(parentDir);

      const subprocess = execa('npx', args, {
        cwd: parentDir,
        stdio: 'inherit',
      });

      await subprocess;

      await Logger.success(`Nx Workspace '${context.projectName}' created successfully.`);

      // Patch nx.json to avoid known issues with scaffolded projects
      await this.ensureNxCompatibility(context);

      // 2. Enforce Directory Structure
      await this.createDirectoryStructure(context);

      // 3. Generate Shared Libraries
      await this.generateSharedLibs(context);

      // 4. Generate Applications
      await this.generateBackend(context);
      await this.generateFrontend(context);
      await this.generateMobile(context);
      await this.generateDesktop(context);

    } catch (error) {
      const errorMessage = (error as Error).message;
      await Logger.error(`Failed to create Nx Workspace: ${errorMessage}`);
      throw error;
    }
  }

  private async execInWorkspace(command: string, args: string[], context: ScaffoldContext): Promise<void> {
    
    // Auto-silence npm install commands to reduce deprecation noise
    if (command === 'npm' && args.includes('install')) {
      if (!args.includes('--loglevel')) args.push('--loglevel=error');
      if (!args.includes('--no-audit')) args.push('--no-audit');
      if (!args.includes('--no-fund')) args.push('--no-fund');
    }

    await Logger.debug(`Executing in workspace: ${command} ${args.join(' ')}`);
    
    // Disable Nx Daemon to prevent race conditions/null errors during scaffolding
    const env: NodeJS.ProcessEnv = { ...process.env };
    if (command === 'nx' || (command === 'npx' && args[0] === 'nx')) {
      env['NX_DAEMON'] = 'false';
    }

    await execa(command, args, {
      cwd: context.targetDirectory,
      stdio: 'inherit',
      env
    });
  }

  private async createDirectoryStructure(context: ScaffoldContext): Promise<void> {
    await Logger.info('Configuring enterprise directory structure...');
    
    const dirs = [];
    
    if (context.apps.nest) dirs.push('apps/backend');
    if (context.apps.react) dirs.push('apps/frontend');
    if (context.apps.mobile) dirs.push('apps/mobile');
    if (context.apps.desktop) dirs.push('apps/desktop');
    
    if (context.libs.shared) {
      dirs.push('libs/types');
      dirs.push('libs/utils');
      dirs.push('libs/enums');
      if (context.apps.react) dirs.push('libs/components');
    }

    for (const dir of dirs) {
      const fullPath = path.join(context.targetDirectory, dir);
      await fse.ensureDir(fullPath);
      await Logger.debug(`Created directory: ${dir}`);
    }
    
    await Logger.success('Directory structure enforced.');
  }

  private async generateSharedLibs(context: ScaffoldContext): Promise<void> {
    if (!context.libs.shared) return;

    await Logger.info('Generating shared libraries...');

    // Install plugin to ensure @nx/js:lib is available
    await this.execInWorkspace('npm', ['install', '-D', '@nx/js'], context);

    const libs = ['types', 'utils', 'enums'];
    
    // Determine scope for import path
    // If organization is 'personal', use project name as scope
    const scope = context.organization === 'personal' ? context.projectName : context.organization;

    for (const lib of libs) {
       await Logger.info(`Generating lib: ${lib}`);
       // nx g @nx/js:lib --name types --directory=libs/types --importPath=@scope/types --unitTestRunner=none --bundler=tsc
       await this.execInWorkspace('npx', [
         'nx', 'g', '@nx/js:lib',
         '--name', lib,
         `--directory=libs/${lib}`,
         `--importPath=@${scope}/${lib}`,
         '--tags=type:util,scope:shared',
         '--unitTestRunner=none',
         '--bundler=tsc',
         '--linter=none'
       ], context);
    }
    
    await Logger.success('Shared libraries generated.');
  }

  private async generateBackend(context: ScaffoldContext): Promise<void> {
    if (!context.apps.nest) return;

    await Logger.info('Generating NestJS Backend...');

    // Install plugin
    await this.execInWorkspace('npm', ['install', '-D', '@nx/nest'], context);

    // Generate App
    // nx g @nx/nest:app {project}-service --directory=apps/backend --tags=type:app,scope:backend
    await this.execInWorkspace('npx', [
      'nx', 'g', '@nx/nest:app',
      '--name', `${context.projectName}-service`,
      `--directory=apps/backend/${context.projectName}-service`,
      '--tags=type:app,scope:backend',
      // Removed --frontendProject to prevent failures if client doesn't exist yet
      '--linter=none',
      '--unitTestRunner=none',
      `--e2eTestRunner=${context.enableE2E ? 'jest' : 'none'}`
    ], context);

    await Logger.success('NestJS Backend generated.');
  }

  private async generateFrontend(context: ScaffoldContext): Promise<void> {
    if (!context.apps.react) return;

    await Logger.info('Generating React Frontend...');

    // Install plugin
    await this.execInWorkspace('npm', ['install', '-D', '@nx/react', '@nx/vite'], context);

    // Generate App
    // nx g @nx/react:app {project}-client --directory=apps/frontend --style=css --bundler=vite
    await this.execInWorkspace('npx', [
      'nx', 'g', '@nx/react:app',
      '--name', `${context.projectName}-client`,
      '--directory=apps/frontend',
      '--style=css',
      '--bundler=vite',
      '--tags=type:app,scope:frontend',
      '--linter=none',
      '--unitTestRunner=none',
      '--routing=true',
      `--e2eTestRunner=${context.enableE2E ? 'cypress' : 'none'}`
    ], context);

    await Logger.success('React Frontend generated.');
  }

  private async generateMobile(context: ScaffoldContext): Promise<void> {
    if (!context.apps.mobile) return;

    await Logger.info('Generating Expo Mobile App...');

    if (context.enableE2E) {
      await Logger.warn('Mobile E2E (Detox) skipped to ensure environment stability on Windows.');
    }

    // Install @nx/expo
    await this.execInWorkspace('npm', ['install', '-D', '@nx/expo'], context);

    const appName = `${context.projectName}-mobile`;

    await this.execInWorkspace('npx', [
      'nx', 'g', '@nx/expo:app',
      '--name', appName,
      `--directory=apps/mobile/${appName}`,
      '--tags=type:app,scope:mobile',
      '--linter=none',
      '--unitTestRunner=none',
      '--e2eTestRunner=none'
    ], context);

    // NOTE: We intentionally do NOT run `expo install --fix` here. The
    // Nx Expo generator only stages package.json changes — the new deps
    // (e.g. jest-expo) aren't on disk until the next workspace-level
    // `npm install`. Running expo's resolver here fails with
    //   "<pkg> is added as a dependency but it doesn't seem to be installed".
    // The fix is run later by DependencyManager AFTER the standard-stack
    // install has populated node_modules. See `expo install --fix` step
    // there (and the `mobile:install` script for manual re-runs).

    await Logger.success('Expo Mobile App generated.');
  }

  private async generateDesktop(context: ScaffoldContext): Promise<void> {
    if (!context.apps.desktop) return;

    // Logic Check: Only attempt nx-electron if React client exists
    if (context.apps.react) {
      await Logger.info('Generating Electron Desktop App...');
      try {
        await this.execInWorkspace('npm', ['install', '-D', 'nx-electron'], context);

        // nx-electron prepends `apps/` to whatever `--directory` we pass,
        // so we provide the path RELATIVE to apps/. Passing
        // `--directory=apps/desktop/<name>` produced `apps/apps/desktop/<name>`.
        const desktopName = `${context.projectName}-desktop`;
        const args = [
          'nx', 'g', 'nx-electron:app',
          '--name', desktopName,
          `--directory=desktop/${desktopName}`,
          '--tags=type:app,scope:desktop',
          `--frontend-project=${context.projectName}-client`,
        ];

        await this.execInWorkspace('npx', args, context);
        await Logger.success('Electron Desktop App generated.');
        return; // Success, exit
      } catch (error) {
        await Logger.warn(`nx-electron generation failed: ${(error as Error).message}. Attempting fallback to React...`);
      }
    } else {
      await Logger.warn('Skipping Electron (requires React Client). Generating standard React Desktop app...');
    }

    // Fallback Logic (used if !react OR if electron failed)
    try {
      await this.execInWorkspace('npx', [
        'nx', 'g', '@nx/react:app',
        '--name', `${context.projectName}-desktop`,
        '--directory=apps/desktop',
        '--bundler=vite',
        '--style=css',         // Fallback Improvement
        '--routing=false',     // Fallback Improvement
        `--e2eTestRunner=${context.enableE2E ? 'cypress' : 'none'}`, // Fallback Improvement
        '--skipFormat',        // Fallback Improvement
        '--tags=type:app,scope:desktop',
        '--linter=none',
        '--unitTestRunner=none'
      ], context);
      await Logger.success('Desktop App generated (React Placeholder).');
    } catch (fallbackError) {
      await Logger.error(`Desktop generation completely failed: ${(fallbackError as Error).message}`);
    }
  }

  private async ensureNxCompatibility(context: ScaffoldContext): Promise<void> {
    await Logger.info('Ensuring Nx compatibility...');
    const nxJsonPath = path.join(context.targetDirectory, 'nx.json');
    
    // Overwrite nx.json with a minimal known-good configuration to avoid v22+ inference issues
    const minimalNxJson = {
      extends: "nx/presets/npm.json",
      tasksRunnerOptions: {
        default: {
          runner: "nx/tasks-runners/default",
          options: {
            cacheableOperations: ["build", "lint", "test", "e2e"]
          }
        }
      }
    };

    try {
      await fse.writeJson(nxJsonPath, minimalNxJson, { spaces: 2 });
      await Logger.debug('Forced minimal nx.json configuration.');
    } catch (error) {
      await Logger.warn(`Failed to rewrite nx.json: ${(error as Error).message}`);
    }
  }
}
