export enum ProjectType {
  NxWorkspace = 'nx-workspace',
  FullStack = 'full-stack',
  SimpleGit = 'simple-git',
  Terraform = 'terraform',
}

/**
 * Optional NestJS resources the user can opt-in to when scaffolding a
 * backend service. Each flag controls:
 *   1. Which dependencies are installed
 *   2. Which template files are written and how `main.ts` / `app.module.ts`
 *      are composed.
 */
export interface BackendResources {
  /** Swagger / OpenAPI docs at `/<prefix>/docs`, protected by basic auth. */
  swagger: boolean;
  /** Helmet HTTP hardening + `x-powered-by` disabled. */
  helmet: boolean;
  /** Pino HTTP logger via `nestjs-pino`. */
  pino: boolean;
  /** `@nestjs/schedule` for cron jobs. */
  schedule: boolean;
  /** `@nestjs/event-emitter` for in-process events. */
  eventEmitter: boolean;
  /** Telegram MTProto user-client + Bot API control surface (telepoly pattern). */
  telegram: boolean;
  /** Drizzle ORM module skeleton (Postgres). */
  drizzle: boolean;
}

export interface ScaffoldContext {
  /**
   * The lowercase, kebab-case name used for the workspace folder, the Nx
   * workspace itself, package.json `name`, generated app/lib names, etc.
   * Nx and npm both reject capitalised names — keep this lowercase.
   */
  projectName: string;
  /**
   * The name to use when creating the GitHub repository. Preserves the
   * casing the user typed (e.g. `Novatrade`). Defaults to {@link projectName}
   * when the user provides an already-lowercase value.
   */
  repoName: string;
  targetDirectory: string;
  projectType: ProjectType;
  organization: string;
  enableE2E: boolean;
  /** Human-friendly title used for Swagger / README. Defaults to PascalCase(projectName). */
  displayName: string;
  apps: {
    nest: boolean;
    react: boolean;
    mobile: boolean;
    desktop: boolean;
  };
  libs: {
    shared: boolean;
  };
  backend: BackendResources;
}
