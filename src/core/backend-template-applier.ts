import fse from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';
import { BackendResources, ScaffoldContext } from '../types/scaffold-context.js';
import { Logger } from '../utils/logger.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/** Repo root for resolving the bundled `templates/` directory. */
const REPO_ROOT = path.resolve(__dirname, '../../');
const TEMPLATE_ROOT = path.join(REPO_ROOT, 'templates');

/**
 * Strip blocks delimited by `// @if:flag` / `// @endif:flag` comments based
 * on the resource flags. Lines outside any block are kept as-is. Lines that
 * remain inside a block whose flag is `false` are removed entirely.
 *
 * The marker style works for `.ts`, `.js`, and `.tsx` files. We deliberately
 * avoid `#if` / `#endif` to keep templates valid TypeScript so editors don't
 * choke on them.
 */
function stripConditionalBlocks(source: string, resources: BackendResources): string {
  const lines = source.split(/\r?\n/);
  const out: string[] = [];
  const stack: { flag: keyof BackendResources; keep: boolean }[] = [];

  const ifRe = /^\s*\/\/\s*@if:([a-zA-Z]+)\s*$/;
  const endRe = /^\s*\/\/\s*@endif(?::[a-zA-Z]+)?\s*$/;

  for (const line of lines) {
    const ifMatch = ifRe.exec(line);
    if (ifMatch) {
      const flag = ifMatch[1] as keyof BackendResources;
      stack.push({ flag, keep: !!resources[flag] });
      continue;
    }
    if (endRe.exec(line)) {
      stack.pop();
      continue;
    }
    if (stack.every((entry) => entry.keep)) {
      out.push(line);
    }
  }

  return out.join('\n');
}

/**
 * Write {@link content} to {@link filePath}, ensuring parent directories exist.
 * Always overwrites — these helpers are run after the Nx generator and are
 * meant to replace the boilerplate it produced.
 */
async function writeFile(filePath: string, content: string): Promise<void> {
  await fse.ensureDir(path.dirname(filePath));
  await fse.writeFile(filePath, content, 'utf-8');
}

async function readTemplate(relativePath: string): Promise<string> {
  return fse.readFile(path.join(TEMPLATE_ROOT, relativePath), 'utf-8');
}

/**
 * Applies post-Nx template overlays specific to NestJS backend services:
 *   - main.ts (helmet, swagger, validation pipe, error handlers)
 *   - app.module.ts (pino, schedule, eventEmitter, telegram wiring)
 *   - env/* (class-validator validation pattern from telepoly)
 *   - common/atomic-write.ts utility
 *   - Optional telegram and drizzle modules
 */
export class BackendTemplateApplier {
  async apply(context: ScaffoldContext): Promise<void> {
    if (!context.apps.nest) return;

    const serviceRoot = path.join(
      context.targetDirectory,
      'apps',
      'backend',
      `${context.projectName}-service`,
      'src',
    );

    if (!(await fse.pathExists(serviceRoot))) {
      await Logger.warn(`Backend src not found at ${serviceRoot} — skipping template overlay.`);
      return;
    }

    await Logger.info('Applying backend template overlay...');

    await this.writeMain(context, serviceRoot);
    await this.writeAppModule(context, serviceRoot);
    await this.writeEnv(context, serviceRoot);
    await this.writeCommon(serviceRoot);

    if (context.backend.telegram) await this.writeTelegram(context, serviceRoot);
    if (context.backend.drizzle) await this.writeDrizzle(serviceRoot);

    await this.patchProjectJson(context);

    await Logger.success('Backend template overlay applied.');
  }

  private async writeMain(context: ScaffoldContext, serviceRoot: string): Promise<void> {
    const tmpl = await readTemplate('backend/main.ts.tmpl');
    const rendered = stripConditionalBlocks(tmpl, context.backend).replaceAll(
      '__DISPLAY_NAME__',
      context.displayName,
    );
    await writeFile(path.join(serviceRoot, 'main.ts'), rendered);
  }

  private async writeAppModule(context: ScaffoldContext, serviceRoot: string): Promise<void> {
    const tmpl = await readTemplate('backend/app.module.ts.tmpl');
    const rendered = stripConditionalBlocks(tmpl, context.backend);
    await writeFile(path.join(serviceRoot, 'app.module.ts'), rendered);
  }

  private async writeEnv(context: ScaffoldContext, serviceRoot: string): Promise<void> {
    const envDir = path.join(serviceRoot, 'env');
    const partsDir = path.join(envDir, 'parts');

    await writeFile(path.join(envDir, 'env.module.ts'), await readTemplate('backend/env/env.module.ts.tmpl'));
    await writeFile(path.join(envDir, 'env.service.ts'), await readTemplate('backend/env/env.service.ts.tmpl'));
    await writeFile(path.join(partsDir, 'env.core.ts'), await readTemplate('backend/env/parts/env.core.ts.tmpl'));

    // Build inheritance chain dynamically: CoreEnv -> [TelegramEnv] -> [DrizzleEnv]
    const imports: string[] = [];
    let extendsClass = 'CoreEnv';
    imports.push(`import { CoreEnv } from './parts/env.core';`);

    if (context.backend.telegram) {
      await writeFile(
        path.join(partsDir, 'env.telegram.ts'),
        await readTemplate('backend/env/parts/env.telegram.ts.tmpl'),
      );
      imports.push(`import { TelegramEnv } from './parts/env.telegram';`);
      extendsClass = 'TelegramEnv';
    }

    if (context.backend.drizzle) {
      // Render the drizzle env part with the right base class
      const drizzleTmpl = await readTemplate('backend/env/parts/env.drizzle.ts.tmpl');
      const baseClass = extendsClass; // chain on top of whatever we have so far
      const baseImport =
        baseClass === 'CoreEnv'
          ? `import { CoreEnv } from './env.core';`
          : `import { TelegramEnv } from './env.telegram';`;
      const drizzleRendered = drizzleTmpl
        .replace('__BASE_IMPORT__', baseImport)
        .replaceAll('__BASE_CLASS__', baseClass);
      await writeFile(path.join(partsDir, 'env.drizzle.ts'), drizzleRendered);
      imports.push(`import { DrizzleEnv } from './parts/env.drizzle';`);
      extendsClass = 'DrizzleEnv';
    }

    const validationTmpl = await readTemplate('backend/env/env.validation.ts.tmpl');
    const validation = validationTmpl
      .replace('__IMPORTS__', imports.join('\n'))
      .replaceAll('__EXTENDS__', extendsClass);
    await writeFile(path.join(envDir, 'env.validation.ts'), validation);
  }

  private async writeCommon(serviceRoot: string): Promise<void> {
    await writeFile(
      path.join(serviceRoot, 'common', 'atomic-write.ts'),
      await readTemplate('backend/common/atomic-write.ts'),
    );
  }

  private async writeTelegram(context: ScaffoldContext, serviceRoot: string): Promise<void> {
    const dir = path.join(serviceRoot, 'telegram');
    await writeFile(
      path.join(dir, 'telegram.module.ts'),
      await readTemplate('backend/telegram/telegram.module.ts.tmpl'),
    );
    await writeFile(
      path.join(dir, 'telegram.service.ts'),
      await readTemplate('backend/telegram/telegram.service.ts.tmpl'),
    );

    const ctrlTmpl = await readTemplate('backend/telegram/telegram.controller.ts.tmpl');
    const ctrl = context.backend.swagger
      ? ctrlTmpl
          .replace('__SWAGGER_IMPORT__', `import { ApiOperation, ApiTags } from '@nestjs/swagger';`)
          .replace('__SWAGGER_TAGS__', `@ApiTags('telegram')`)
          .replace('__SWAGGER_OPERATION__', `@ApiOperation({ summary: 'Telegram client connection status' })`)
      : ctrlTmpl
          .replace('__SWAGGER_IMPORT__\n', '')
          .replace('__SWAGGER_TAGS__\n', '')
          .replace('  __SWAGGER_OPERATION__\n', '');
    await writeFile(path.join(dir, 'telegram.controller.ts'), ctrl);

    await writeFile(
      path.join(dir, 'bot', 'bot.service.ts'),
      await readTemplate('backend/telegram/bot/bot.service.ts.tmpl'),
    );
  }

  private async writeDrizzle(serviceRoot: string): Promise<void> {
    await writeFile(
      path.join(serviceRoot, 'drizzle', 'drizzle.module.ts'),
      await readTemplate('backend/drizzle/drizzle.module.ts.tmpl'),
    );
  }

  /**
   * Add per-project `format` / `format:check` run-commands targets to the
   * backend service's `project.json` (the telepoly pattern), so callers can
   * run `nx format <service>` instead of having to pass `--projects=`.
   */
  private async patchProjectJson(context: ScaffoldContext): Promise<void> {
    const serviceName = `${context.projectName}-service`;
    const projectJsonPath = path.join(
      context.targetDirectory,
      'apps',
      'backend',
      serviceName,
      'project.json',
    );

    if (!(await fse.pathExists(projectJsonPath))) {
      await Logger.debug(`No project.json at ${projectJsonPath}; skipping format target patch.`);
      return;
    }

    const project = (await fse.readJson(projectJsonPath)) as {
      targets?: Record<string, unknown>;
    };
    project.targets = project.targets ?? {};
    project.targets['format'] = {
      executor: 'nx:run-commands',
      options: {
        command: `nx format:write --projects=${serviceName}`,
        cwd: '{workspaceRoot}',
      },
    };
    project.targets['format:check'] = {
      executor: 'nx:run-commands',
      options: {
        command: `nx format:check --projects=${serviceName}`,
        cwd: '{workspaceRoot}',
      },
    };

    await fse.writeJson(projectJsonPath, project, { spaces: 2 });
    await Logger.debug(`Patched ${serviceName}/project.json with format targets.`);
  }
}
