import fse from 'fs-extra';
import inquirer from 'inquirer';
import path from 'path';
import { ConfigManager } from '../config/config-manager.js';
import { BackendResources, ProjectType, ScaffoldContext } from '../types/scaffold-context.js';

function toPascalCase(input: string): string {
  return input
    .split(/[-_\s]+/)
    .filter(Boolean)
    .map((s) => s.charAt(0).toUpperCase() + s.slice(1).toLowerCase())
    .join('');
}

/**
 * Convert any user-supplied project name into a lowercase, kebab-case
 * identifier safe for Nx workspace names, npm package names, and folder
 * paths. Examples:
 *   "Novatrade"        -> "novatrade"
 *   "My Cool App"      -> "my-cool-app"
 *   "MyCoolApp"        -> "my-cool-app"
 *   "create-github"    -> "create-github"
 */
function toKebabCase(input: string): string {
  return input
    .trim()
    // Insert a hyphen between a lowercase/digit and an uppercase letter
    // (e.g. "MyCoolApp" -> "My-Cool-App").
    .replace(/([a-z0-9])([A-Z])/g, '$1-$2')
    // Collapse whitespace and underscores into hyphens.
    .replace(/[\s_]+/g, '-')
    .toLowerCase()
    // Collapse runs of hyphens and trim them off the ends.
    .replace(/-+/g, '-')
    .replace(/^-+|-+$/g, '');
}

/**
 * Helper to find the workspace root by looking for nx.json or .git
 * recursing upwards from the current directory.
 */
function findWorkspaceRoot(startDir: string): string | null {
  let currentDir = startDir;
  while (currentDir !== path.parse(currentDir).root) {
    if (fse.existsSync(path.join(currentDir, 'nx.json')) || fse.existsSync(path.join(currentDir, '.git'))) {
      return currentDir;
    }
    const parentDir = path.dirname(currentDir);
    if (parentDir === currentDir) break; // Reached root or cannot go up
    currentDir = parentDir;
  }
  return null;
}

export async function promptUser(
  configManager: ConfigManager, 
  options: { location?: string } = {}
): Promise<ScaffoldContext> {
  const defaultOrg = configManager.get('defaultOrganization');

  const answers = await inquirer.prompt([
    {
      type: 'input',
      name: 'projectName',
      message: 'Project Name (e.g. "Novatrade" or "my-app"):',
      filter: (input: string) => input.trim(),
      validate: (input: string) => {
        const value = input.trim();
        if (!value) return 'Project name is required';
        // Allow letters (any case), digits, hyphens, underscores, spaces.
        // We'll lowercase + kebab-case it for Nx and keep the original for GitHub.
        if (!/^[A-Za-z0-9][A-Za-z0-9\-_ ]*$/.test(value)) {
          return 'Project name may only contain letters, digits, hyphens, underscores, and spaces (must start with a letter or digit).';
        }
        return true;
      },
    },
    {
      type: 'list',
      name: 'projectType',
      message: 'Select Project Type:',
      choices: [
        { name: 'Enterprise Nx Monorepo     (NestJS, React, Shared Libs)', value: ProjectType.NxWorkspace },
        { name: 'Full Stack Platform        (Nx Monorepo + Terraform Infra + GitHub Actions)', value: ProjectType.FullStack },
        { name: 'Simple Git Repository      (Standard .gitignore + README)', value: ProjectType.SimpleGit },
        { name: 'Terraform Infrastructure   (Modules, Environments, Remote State)', value: ProjectType.Terraform },
      ],
    },
    {
      type: 'list',
      name: 'orgChoice',
      message: 'Select Organization:',
      choices: [
        { name: 'Personal Project (No Organization)', value: 'personal' },
        ...(defaultOrg ? [{ name: `Default Organization (${defaultOrg})`, value: 'default' }] : []),
        { name: 'Custom Organization (Enter Name manually)', value: 'custom' },
      ],
    },
    {
      type: 'input',
      name: 'customOrg',
      message: 'Enter Organization Name:',
      when: (answers) => answers.orgChoice === 'custom',
      validate: (input) => !!input || 'Organization name is required',
    },
    {
      type: 'checkbox',
      name: 'features',
      message: 'Select Features to Enable:',
      choices: [
        { name: 'NestJS Server', value: 'nest', checked: true },
        { name: 'React Client', value: 'react', checked: true },
        { name: 'Mobile App (Expo)', value: 'mobile' },
        { name: 'Desktop App (Electron)', value: 'desktop' },
        { name: 'Shared Libraries (Types, Utils, Enums - Enterprise Standards)', value: 'shared', checked: true },
      ],
      when: (answers) =>
        answers.projectType === ProjectType.NxWorkspace || answers.projectType === ProjectType.FullStack,
    },
    {
      type: 'checkbox',
      name: 'backendResources',
      message: 'Select Backend Resources (NestJS service):',
      choices: [
        { name: 'Swagger / OpenAPI docs (basic-auth protected)', value: 'swagger', checked: true },
        { name: 'Helmet (HTTP hardening)', value: 'helmet', checked: true },
        { name: 'Pino HTTP Logger (nestjs-pino, pretty in dev)', value: 'pino', checked: true },
        { name: '@nestjs/schedule (cron jobs)', value: 'schedule' },
        { name: '@nestjs/event-emitter (in-process events)', value: 'eventEmitter' },
        { name: 'Telegram (MTProto user client + Bot API control panel)', value: 'telegram' },
        { name: 'Drizzle ORM module skeleton (Postgres)', value: 'drizzle' },
      ],
      when: (answers) =>
        (answers.projectType === ProjectType.NxWorkspace || answers.projectType === ProjectType.FullStack) &&
        (answers.features ?? []).includes('nest'),
    },
    {
      type: 'input',
      name: 'displayName',
      message: 'Display Name (used for Swagger title / README):',
      default: (answers: { projectName: string }) => toPascalCase(answers.projectName),
    },
    {
      type: 'confirm',
      name: 'enableE2E',
      message: 'Generate E2E testing projects for each application?',
      default: false,
      when: (answers) =>
        answers.projectType === ProjectType.NxWorkspace || answers.projectType === ProjectType.FullStack,
    },
    {
      type: 'confirm',
      name: 'saveDefaults',
      message: 'Save organization as default for future projects?',
      default: false,
      when: (answers) => answers.orgChoice === 'custom',
    },
  ]);

  // Handle Persistence
  if (answers.saveDefaults && answers.customOrg) {
    configManager.set('defaultOrganization', answers.customOrg);
  }

  // Map to Context
  let organization = 'personal';
  if (answers.orgChoice === 'default') organization = defaultOrg || 'personal';
  if (answers.orgChoice === 'custom') organization = answers.customOrg;

  const features = answers.features || [];
  const backendResourceList: string[] = answers.backendResources || [];
  const backend: BackendResources = {
    swagger: backendResourceList.includes('swagger'),
    helmet: backendResourceList.includes('helmet'),
    pino: backendResourceList.includes('pino'),
    schedule: backendResourceList.includes('schedule'),
    eventEmitter: backendResourceList.includes('eventEmitter'),
    telegram: backendResourceList.includes('telegram'),
    drizzle: backendResourceList.includes('drizzle'),
  };

  // Determine Target Directory
  // The folder name uses the lowercase/kebab form; capitalised names are kept
  // around only for the GitHub repo (see `repoName`).
  const rawName: string = answers.projectName;
  const projectName = toKebabCase(rawName);
  const repoName = rawName.includes(' ') ? toKebabCase(rawName) : rawName;

  let targetDirectory: string;

  if (options.location) {
    // 1. Explicit Flag: Use provided location as parent
    targetDirectory = path.resolve(options.location, projectName);
  } else {
    // 2. Smart Default: Check for Workspace Root
    const workspaceRoot = findWorkspaceRoot(process.cwd());
    if (workspaceRoot) {
      // Create as sibling to the found workspace root
      targetDirectory = path.resolve(path.dirname(workspaceRoot), projectName);
    } else {
      // 3. Fallback: CWD
      targetDirectory = path.join(process.cwd(), projectName);
    }
  }

  return {
    projectName,
    repoName,
    targetDirectory,
    projectType: answers.projectType,
    organization,
    enableE2E: answers.enableE2E ?? false,
    displayName: answers.displayName || toPascalCase(projectName),
    apps: {
      nest: features.includes('nest'),
      react: features.includes('react'),
      mobile: features.includes('mobile'),
      desktop: features.includes('desktop'),
    },
    libs: {
      shared: features.includes('shared'),
    },
    backend,
  };
}
