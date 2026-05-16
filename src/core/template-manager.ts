import fse from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';
import { ScaffoldContext } from '../types/scaffold-context.js';
import { Logger } from '../utils/logger.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const REPO_ROOT = path.resolve(__dirname, '../../');
const TEMPLATE_ROOT = path.join(REPO_ROOT, 'templates');

export class TemplateManager {
  async copyAssets(context: ScaffoldContext): Promise<void> {
    await Logger.info('Copying infrastructure and CI/CD assets...');

    const assets = [
      { src: 'infrastructure', dest: 'infrastructure' },
      { src: '.github', dest: '.github' },
    ];

    for (const asset of assets) {
      const sourcePath = path.join(REPO_ROOT, asset.src);
      const destPath = path.join(context.targetDirectory, asset.dest);

      if (await fse.pathExists(sourcePath)) {
        await Logger.debug(`Copying ${sourcePath} to ${destPath}`);
        await fse.copy(sourcePath, destPath, {
          overwrite: true,
          errorOnExist: false,
          filter: (src) => {
            const normalizedSrc = src.replace(/\\/g, '/');
            if (normalizedSrc.includes('/node_modules/') || normalizedSrc.endsWith('/node_modules')) return false;
            if (normalizedSrc.includes('/.git/') || normalizedSrc.endsWith('/.git')) return false;
            if (normalizedSrc.includes('/.github/prompts')) return false;
            return true;
          },
        });
        await Logger.success(`Copied ${asset.src} to project.`);
      } else {
        await Logger.warn(`Asset source not found: ${sourcePath}`);
      }
    }

    await this.disableWorkflowTriggers(context);
    await this.copyWorkspaceTemplates(context);
  }

  /**
   * Comment out the `on:` trigger block in every copied GitHub Actions workflow
   * so freshly-scaffolded projects don't auto-run pipelines (which will fail
   * before infra/secrets are wired up and cost CI minutes). Users can
   * re-enable by uncommenting the block.
   */
  private async disableWorkflowTriggers(context: ScaffoldContext): Promise<void> {
    const workflowsDir = path.join(context.targetDirectory, '.github', 'workflows');
    if (!(await fse.pathExists(workflowsDir))) return;

    const entries = await fse.readdir(workflowsDir);
    const workflowFiles = entries.filter((f) => /\.ya?ml$/i.test(f));

    for (const file of workflowFiles) {
      const filePath = path.join(workflowsDir, file);
      const original = await fse.readFile(filePath, 'utf-8');
      const updated = this.commentOutOnBlock(original);
      if (updated !== original) {
        await fse.writeFile(filePath, updated, 'utf-8');
        await Logger.debug(`Disabled triggers in .github/workflows/${file}`);
      }
    }

    if (workflowFiles.length > 0) {
      await Logger.success(`Commented out triggers in ${workflowFiles.length} workflow file(s). Uncomment the \`on:\` block to enable.`);
    }
  }

  /**
   * Comment out a top-level `on:` block in a YAML workflow file. Begins at the
   * `on:` line (column 0) and continues through every following blank or
   * indented line until the next top-level key.
   */
  private commentOutOnBlock(source: string): string {
    const lines = source.split(/\r?\n/);
    const out: string[] = [];
    let inOnBlock = false;
    let injectedNotice = false;

    for (const line of lines) {
      if (!inOnBlock && /^on\s*:/.test(line)) {
        inOnBlock = true;
        if (!injectedNotice) {
          out.push('# Triggers disabled by apm-scaffolder. Uncomment to enable CI.');
          injectedNotice = true;
        }
        out.push(`# ${line}`);
        continue;
      }

      if (inOnBlock) {
        // Blank line or indented line belongs to the on: block.
        if (line.trim() === '' || /^[ \t]/.test(line)) {
          out.push(line.trim() === '' ? '#' : `# ${line}`);
          continue;
        }
        // Non-indented, non-blank line -> end of on: block.
        inOnBlock = false;
      }

      out.push(line);
    }

    return out.join('\n');
  }

  /**
   * Drop in workspace-level config files derived from the polished telepoly /
   * oasis-portal-t setups: .gitignore, .editorconfig, .prettierrc, .prettierignore,
   * .vscode/{extensions.json, launch.json}, and an .env.example tailored to the
   * selected backend resources.
   */
  private async copyWorkspaceTemplates(context: ScaffoldContext): Promise<void> {
    const wsRoot = path.join(TEMPLATE_ROOT, 'workspace');
    const target = context.targetDirectory;

    const fileMap: Array<[string, string]> = [
      ['gitignore', '.gitignore'],
      ['editorconfig', '.editorconfig'],
      ['prettierrc', '.prettierrc'],
      ['prettierignore', '.prettierignore'],
      ['vscode/extensions.json', '.vscode/extensions.json'],
    ];

    for (const [src, dest] of fileMap) {
      const srcPath = path.join(wsRoot, src);
      const destPath = path.join(target, dest);
      if (!(await fse.pathExists(srcPath))) continue;
      await fse.ensureDir(path.dirname(destPath));
      await fse.copy(srcPath, destPath, { overwrite: true });
      await Logger.debug(`Wrote ${dest}`);
    }

    if (context.apps.nest) {
      const launchTmpl = await fse.readFile(path.join(wsRoot, 'vscode', 'launch.json.tmpl'), 'utf-8');
      const launchOut = launchTmpl.replaceAll('__SERVICE_NAME__', `${context.projectName}-service`);
      const launchPath = path.join(target, '.vscode', 'launch.json');
      await fse.ensureDir(path.dirname(launchPath));
      await fse.writeFile(launchPath, launchOut, 'utf-8');
      await Logger.debug('Wrote .vscode/launch.json');
    }

    if (context.apps.mobile) {
      const mobileScripts = [
        'write-android-local-properties.mjs',
        'android-preflight.mjs',
      ];
      for (const file of mobileScripts) {
        const scriptSrc = path.join(wsRoot, 'tools', 'scripts', file);
        if (!(await fse.pathExists(scriptSrc))) continue;
        const scriptDest = path.join(target, 'tools', 'scripts', file);
        await fse.ensureDir(path.dirname(scriptDest));
        await fse.copy(scriptSrc, scriptDest, { overwrite: true });
        await Logger.debug(`Wrote tools/scripts/${file}`);
      }
    }

    await this.writeEnvExample(context);
  }

  private async writeEnvExample(context: ScaffoldContext): Promise<void> {
    if (!context.apps.nest) return;
    const wsRoot = path.join(TEMPLATE_ROOT, 'workspace');
    const tmpl = await fse.readFile(path.join(wsRoot, 'env.example.tmpl'), 'utf-8');

    const docsBlock = context.backend.swagger
      ? '\n# ---- Swagger docs basic auth ----\nDOCS_USERNAME="user"\nDOCS_PASSWORD="password"\n'
      : '';

    const telegramBlock = context.backend.telegram
      ? `
# ---- Telegram MTProto (https://my.telegram.org/apps) ----
TELEGRAM_API_ID=""
TELEGRAM_API_HASH=""
TELEGRAM_SESSION=""

# ---- Telegram Bot API (@BotFather) ----
TELEGRAM_BOT_TOKEN=""
# /start to @userinfobot to discover this id
TELEGRAM_ADMIN_CHAT_ID=""
`
      : '';

    const drizzleBlock = context.backend.drizzle
      ? `
# ---- Database (Drizzle / Postgres) ----
DATABASE_URL="postgres://user:password@localhost:5432/${context.projectName}"
`
      : '';

    const rendered = tmpl
      .replaceAll('__DISPLAY_NAME__', context.displayName)
      .replace('__DOCS_BLOCK__', docsBlock)
      .replace('__TELEGRAM_BLOCK__', telegramBlock)
      .replace('__DRIZZLE_BLOCK__', drizzleBlock);

    await fse.writeFile(path.join(context.targetDirectory, '.env.example'), rendered, 'utf-8');
    await Logger.debug('Wrote .env.example');
  }
}
