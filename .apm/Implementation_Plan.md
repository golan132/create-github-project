# Create-Github-Project CLI – APM Implementation Plan
**Memory Strategy:** Dynamic-MD
**Last Modification:** 2026-02-02 (Updated by Manager Agent - Phase 7 In Progress: Restructure Completed)
**Project Overview:** Migration of a legacy Windows Batch script to a robust Node.js/TypeScript CLI tool for scaffolding Enterprise Modorepo Workspaces.

## Problem to Solve
The current project creation process relies on a fragile, hard-to-maintain 1600-line Windows Batch script (`create-github-project.bat`). It lacks robust error handling, has dependencies on the host environment state, and is difficult to extend. The goal is to migrate this logic to a structured, type-safe Node.js CLI tool that reliably scaffolds Enterprise-grade Nx workspaces.

## Proposed Solution
A local Node.js CLI tool written in TypeScript. It will use:
- **`commander`**: For CLI argument parsing and the `--debug` flag.
- **`inquirer`**: For interactive, user-friendly prompts.
- **`execa`**: For robust, error-checked execution of shell commands (`nx`, `git`, `npm`).
- **`fs-extra`**: For reliable file copying and directory management.
- **`conf`**: For storing user preferences (Organization name, defaults) locally.

The tool will enforce strict naming conventions and directory structures (`apps/backend`, `apps/frontend`) and automatically integrate enterprise standard libraries.

## Plan Overview
- **Phase 1: Foundation & CLI Structure**: Initialize the TypeScript project and build the command processing skeleton.
- **Phase 2: Interactive Configuration Module**: Implement the UI prompts and preference persistence.
- **Phase 3: Deep Scaffolding Engine**: The core logic to creating Nx workspaces, generating apps with specific naming rules, and structuring libraries.
- **Phase 4: Asset Integration & Dependencies**: Managing templates, copying infrastructure files, and installing the "Standard Stack".
- **Phase 5: Git Integration & Finalization**: Handling Git/GitHub setup, error recovery, and debug modes.

## Phase 1: Foundation & CLI Structure
**Goal**: specific TypeScript environment setup and basic CLI entry point that can parse arguments and log output safely.

- [ ] **Task 1.1**: Initialize `scaffolder` TypeScript project structure.
    - **Status**: Completed
    - Create `tools/scaffolder` directory to house the source code.
    - Initialize `package.json` and install core dependencies (`typescript`, `ts-node`, `commander`, `chalk`, `execa`, `fs-extra`, `inquirer`).
    - Configure `tsconfig.json` for Node.js execution.
- [ ] **Task 1.2**: Implement robust Logging System.
    - **Status**: Completed
    - Create `Logger` class that supports info, success, warning, and error levels.
    - Implement file-logging (replacing the batch file's log text file) to `setup_log.txt`.
    - Implement "Verbose/Debug" mode toggle.
- [ ] **Task 1.3**: Build CLI Entry Point & Argument Parser.
    - **Status**: Completed
    - Create `index.ts`.
    - Configure `The Command` using `commander` to accept optional flags like `--debug`, `--verbose`, `--dry-run`.
    - Verify basic execution works (e.g., `npx ts-node tools/scaffolder/index.ts --help`).

## Phase 2: Interactive Configuration Module
**Goal**: Replace the batch file's "Type 1, 2, 3" inputs with a rich interactive questionnaire that remembers user preferences.

- [x] **Task 2.1**: Implement Configuration Store.
    - **Status**: Completed
    - Create `ConfigManager` to read/write to a local JSON file (e.g., `.apm-config.json`).
    - Store defaults for Organization Name and Author Name.
- [x] **Task 2.2**: Build Interactive Prompts.
    - **Status**: Completed
    - use `inquirer` to create the flow:
        - Project Name (Validation: regex for kebab-case).
        - Project Type (Selection List).
        - Organization (Choice: Personal vs Custom).
        - Features (Checkboxes: NestJS Server, React Client, Mobile, Desktop).
    - **Optimization**: Support "Fast Mode" where it skips prompts if defaults exist and no flags provided.
- [x] **Task 2.3**: Map User Answers to internal `ScaffoldContext`.
    - **Status**: Completed
    - Define TypeScript interfaces for the "Blueprint" of what needs to be built.
    - Convert user answers into this Blueprint object for the next phase.
- [x] **Task 2.4**: Refine Prompt UX (User Feedback).
    - **Status**: Completed
    - **Goal**: Add detailed examples/descriptions to the input prompts.
    - **Notes**: Fixed critical ESM runtime issues (`inquirer` v9.3.2 downgrade, `fs-extra` import fix).
    - Add descriptive separators or help text to the "Project Type" selection to explain what each option scaffolds (e.g., "Full Stack includes Nx + Terraform + CI/CD").

## Phase 3: Deep Scaffolding Engine
**Goal**: The "Heavy Lifting". Execute `nx` commands to generate the workspace to exact specifications.

- [x] **Task 3.1**: Implement `NxWorkspaceGenerator`.
    - **Status**: Completed
    - Logic to run `npx create-nx-workspace` non-interactively.
    - Handle the initial folder creation.
- [x] **Task 3.2 / 3.3 / 3.4 (Batch)**: Complete Deep Scaffolding Engine.
    - **Status**: Completed
    - **Task 3.2**: Enforce Directory Structure (`apps/backend`, `libs/types`, etc).
    - **Task 3.3**: Implement App Generators (@nx/nest, @nx/react, @nx/expo).
    - **Task 3.4**: Implement Shared Lib Generators (types, utils, enums).
    - **Verification**: Successfully generated a full workspace with `batch-test-01` including:
        - `apps/backend` (NestJS)
        - `apps/frontend` (React + Vite)
        - `apps/mobile` (Expo/React Native)
        - `libs/{types, utils, enums}`
    - **Note**: Fixed Nx Schema issues (positional arguments) for all generators.

## Phase 4: Asset Integration & Dependencies
**Goal**: Copy the static assets (Terraform, Workflows) and install the "Standard Stack".

- [x] **Task 4.1 / 4.2 / 4.3 (Batch)**: Complete Asset & Dependency Integration.
    - **Status**: Completed
    - **Task 4.1**: Implemented `TemplateManager` (Copied `.github` and `infrastructure` folders).
    - **Task 4.2**: Implemented `DependencyManager` (Installed `lodash` backend, `tanstack-query` frontend, etc.).
    - **Task 4.3**: Integrated Nx Console Scripts (Updated `package.json` with convenience scripts).
    - **Verification**: Validated via `verify-batch.ts` with checks for file existence and `package.json` updates.

## Phase 5: Git Integration & Finalization
**Goal**: Initialize source control and handle the "Happy Path" vs "Error Path".

- [x] **Task 5.1 / 5.2 / 5.3 (Batch)**: Complete Git & Tool Finalization.
    - **Status**: Completed
    - **Task 5.1**: Implement Git Initialization.
        - Run `git init` (ensure branch is `main`).
        - Run `git add .` and `git commit`.
        - Create `dev` branch from `main`.
        - Check for `gh` CLI presence and create remote repo if available.
    - **Task 5.2**: Implement Error Handling & Cleanup.
        - Wrap the main execution in a global `try/catch`.
        - On Error: Check for `--debug` flag. Normal = Recursive delete; Debug = Log error.
    - **Task 5.3**: Final Developer Handoff.
        - Print the "Project Setup Complete" summary.
        - Automatically open VS Code (`code .`).

## Phase 7: Restructure & Cleanup
**Goal**: Flatten the project structure and remove legacy artifacts.

- [x] **Task 7.1 / 7.2 (Batch)**: Restructure to Root & Cleanup.
    - **Status**: Completed
    - **Objective**: Move CLI source to root, remove `tools/`, delete `create-github-project.bat` and test scripts.
    - **Outcome**: Project structure flattened, legacy files removed.

- [x] **Task 7.3**: Refine Template Copying.
    - **Status**: Completed
    - **Objective**: Update `TemplateManager` to exclude `.github/prompts` when copying the `.github` folder.
    - **Outcome**: Modified `copyAssets` with a robust filter to exclude prompts.

- [x] **Task 7.4**: Update & Refactor README.
    - **Status**: Completed
    - **Objective**: Refactor README.md to reflect the new flattened project structure and updated usage instructions.
    - **Outcome**: README rewrite complete. Old sections removed, new usage commands (`npm run dev`) added.

- [x] **Task 7.5**: Fix Nx Generator Error (Blocker).
    - **Status**: Failed (Regression)
    - **Objective**: Resolve `Cannot read properties of null (reading 'useInferencePlugins')`.
    - **Outcome**: The `ensureNxCompatibility` patch did not resolve the issue. Error persists.

- [x] **Task 7.6**: Definitive Nx Compatibility Fix.
    - **Status**: Completed
    - **Objective**: Force a known-good `nx.json` state and disable Nx Daemon.
    - **Outcome**: Overwrote `nx.json` with minimal config and set `NX_DAEMON=false`.

- [x] **Task 7.7**: Fix Project Location & Nx.json (Regression).
    - **Status**: Completed
    - **Objective**: Fix `create-nx-workspace` execution CWD.
    - **Outcome**: Updated `NxWorkspaceGenerator` to run `create-nx-workspace` in the parent of `targetDirectory`.

- [x] **Task 7.8**: Fix Git Remote Push & Personal Org.
    - **Status**: Completed
    - **Objective**: Ensure GitHub repository is created correctly for "personal" projects and ALL branches (`main` and `dev`) are pushed.
    - **Outcome**: Updated `GitManager` to handle 'personal' org and explicitly push `main` and `dev`.

- [x] **Task 7.9**: Implement Desktop App Generator.
    - **Status**: Completed
    - **Objective**: Populate `apps/desktop` which is currently created empty.
    - **Outcome**: Implemented `generateDesktop` using `nx-electron` with a fallback to React. Updated `initWorkspace` to call it.

- [x] **Task 7.10**: Fix Desktop Generator Logic.
    - **Status**: Completed
    - **Objective**: Fix `nx-electron` failure when React is missing and suppress fallback prompts.
    - **Outcome**: `generateDesktop` now checks `context.apps.react`. Flags updated. Fallback is now silent (non-interactive).

- [x] **Task 7.11**: Disable E2E for Backend.
    - **Status**: Completed
    - **Objective**: Remove e2e test generation for NestJS backend.
    - **Outcome**: Added `--e2eTestRunner=none` to `generateBackend`.

- [x] **Task 7.12**: Fix Mobile React Version Mismatch.
    - **Status**: Completed
    - **Objective**: Resolve "Invalid hook call" in Mobile App caused by React version usage.
    - **Outcome**: Pinned `react@18.2.0`, `react-dom@18.2.0`, and `react-native@0.74.5` in `DependencyManager`. Updated `NxGenerator` to use `@nx/react-native` with Webpack, matching user's successful manual configuration.

- [x] **Task 7.13**: Resolve NPM Deprecation Warnings.
    - **Status**: Completed
    - **Objective**: Minimize deprecation warnings (`glob`, `rimraf`, `@babel/plugin-proposal-*`) during `installStandardStack`.
    - **Context**: These warnings come from transitive dependencies in the `@nx` ecosystem and `nx-electron`. While not critical errors, they pollute the log.
    - **Action**: Use `npm install --no-warnings` or explicitly update overrides in `package.json` to newer versions if compatible. Since we can't easily control transitive deps of Nx, we will flag `install` commands with `--no-warnings` to clean up the user experience, while keeping critical errors.

- [x] **Task 7.14**: Feature: Optional E2E & Explicit TypeScript.
    - **Status**: Completed
    - **Objective**: Ask user if they want E2E projects.
    - **Outcome**: Added prompt `enableE2E`. Toggles Cypress/Jest for Web/Backend. Skipped for Mobile (stability).

## Phase 8: Production Readiness
**Goal**: Configure the project for distribution and production usage (compilation, bin configuration).

- [ ] **Task 8.1**: Package Configuration.
    - **Status**: Pending
    - **Objective**: Update `package.json` (name, bin entry, build scripts) and `tsconfig.json` (outDir).
    - **Context**: The CLI needs to be buildable (`tsc`) and executable via `bin` linking.

- [ ] **Task 8.2**: Build Verification.
    - **Status**: Pending
    - **Objective**: Run the build process and verify the output in `dist/`.
    - **Context**: Ensure the TypeScript compiles correctly to ES Modules that Node can run.




