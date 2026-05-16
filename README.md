# Create-Github-Project CLI

A robust Node.js/TypeScript CLI tool for scaffolding Enterprise-grade Nx Workspaces. This tool automates the creation of full-stack project structures with backend services, frontend applications, and strict infrastructure standards.

## Features

### 🏗️ Supported Architectures

- **Enterprise Nx Monorepo**:
  - **Backend**: NestJS with standardized service/repository patterns.
  - **Frontend**: React (Vite) + Material UI + TanStack Query.
  - **Shared Libraries**: Strictly typed DTOs, utilities, and UI components (`libs/types`, `libs/utils`, etc.).
- **Infrastructure**: Integrated Terraform templates for multiple environments (Dev/Prod).
- **CI/CD**: Pre-configured GitHub Actions for building, testing, and releasing.

### 🚀 Key Capabilities

- **Smart Scaffolding**: Enforces consistent naming conventions and directory structures.
- **Dependency Injection**: Auto-installs and configures essential enterprise dependencies (`class-validator`, `lodash/fp`, `drizzle-orm`).
- **Git Integration**: Initializes repository, renames `master` to `main`, and creates initial commits.
- **Location Strategy**: Automatically detects if you are inside an existing workspace and places new projects as siblings.

## Prerequisites

- **Node.js** (v18 or higher)
- **Git**
- **GitHub CLI (`gh`)** (Optional, for remote repository creation)

## Usage

### Running Locally

You can run the tool directly from the source:

```bash
# Install dependencies
npm install

# Run the wizard
npm run dev

# Run with arguments
npm run dev -- --location "C:/My/Projects"
```

### Command Line Options

| Flag                    | Best For     | Description                                                |
| :---------------------- | :----------- | :--------------------------------------------------------- |
| `-l, --location <path>` | CI / Scripts | Manually specify the parent directory for the new project. |
| `-h, --help`            | Info         | Display help information.                                  |

### Project Location Strategy

The CLI uses a "Smart Default" strategy to decide where to create your project:

1.  **Sibling Mode (Default)**: If run inside an existing repo (e.g., `C:/Repos/ProjectA`), it creates the new project next to it (`C:/Repos/NewProject`).
2.  **Current Directory**: If no repository is detected, it creates the project in the current working directory.
3.  **Custom Location**: Use `-l` or `--location` to override the behavior.

## Development

### Project Structure

The CLI codebase is a standard TypeScript project:

```text
src/
├── core/           # Main logic (Scaffolder, TemplateManager)
├── generators/     # Nx command generators
├── services/       # Git, GitHub, and System services
├── types/          # Internal interfaces
└── utils/          # Logging and helper functions
```

### Building the CLI

To compile the TypeScript code to JavaScript (ESM):

```bash
npm run build
```

The output will be generated in the `dist/` directory.

### Contributing

1.  Fork the repository.
2.  Create a feature branch (`git checkout -b feature/amazing-feature`).
3.  Commit your changes (`git commit -m 'Add amazing feature'`).
4.  Push to the branch (`git push origin feature/amazing-feature`).
5.  Open a Pull Request.