# Project Template Generator

A comprehensive batch script for creating various types of projects with automated GitHub setup, CI/CD workflows, and infrastructure templates.

## Features

### Project Types
1. **NX Workspace** - Full-featured monorepo with NestJS/React support
2. **Simple Git Repository** - Basic repository for simple projects
3. **Terraform Infrastructure Project** - Infrastructure-as-Code project
4. **Full Stack Project** - Combined NX workspace with Terraform infrastructure

### Infrastructure Support
- **Basic Level** - Networking module only (VPC, subnets, security groups)
- **Standard Level** - Networking + Computing (ECS clusters)
- **Full Level** - Complete infrastructure (networking, computing, database, secrets, services)

### GitHub Integration
- Automatic repository creation with customizable visibility
- Pre-configured workflows for CI/CD
- Reusable GitHub Actions for common tasks
- Release management with release-please

## Prerequisites

Before using this script, ensure you have:

1. **Node.js** (version 14 or higher)
2. **npm** or **pnpm**
3. **Git** configured with your credentials
4. **GitHub CLI** (`gh`) installed and authenticated
5. **Terraform** (if using infrastructure features)
6. **AWS CLI** configured (if using AWS infrastructure)

### GitHub CLI Setup
```bash
# Install GitHub CLI
# Windows: winget install GitHub.cli
# macOS: brew install gh

# Authenticate with GitHub
gh auth login
```

## Usage

1. Clone or download this repository
2. Navigate to the project directory
3. Run the script:
   ```batch
   create-github-project.bat
   ```
4. Follow the interactive prompts to configure your project

### Project Configuration Options

#### Project Type Selection
- **Type 1: NX Workspace** - Creates a modern monorepo setup
- **Type 2: Simple Repository** - Creates a basic Git repository
- **Type 3: Terraform Project** - Creates infrastructure-only project
- **Type 4: Full Stack** - Combines NX workspace with Terraform infrastructure

#### NX Workspace Options
- **NestJS Server** - Backend API with NestJS framework
- **React Client** - Frontend application with React and Vite
- **Shared Libraries** - Automatically created when both server and client are selected

#### Infrastructure Options
- **Infrastructure Name** - Custom name for your infrastructure stack
- **Infrastructure Level**:
  - **Basic**: VPC, subnets, security groups
  - **Standard**: Basic + ECS cluster and computing resources
  - **Full**: Standard + RDS database, Secrets Manager, ECR, and ECS services

#### GitHub Repository Options
- **Organization** - Personal or custom organization
- **Visibility** - Public, private, or internal (for organizations)

## Generated Structure

### NX Workspace Structure
```
project-name/
├── apps/
│   ├── server-name/          # NestJS application
│   └── client-name/          # React application
├── libs/
│   └── types/               # Shared type definitions
├── .github/
│   ├── workflows/
│   │   ├── deploy-NX-projects.yaml
│   │   └── release-please.yml
│   └── actions/
│       ├── nx-setup/
│       ├── build-project/
│       ├── build-push/
│       ├── identify-affected-proj/
│       └── assume-role/
├── nx.json
├── package.json
└── README.md
```

### Infrastructure Structure
```
infrastructure/
└── infrastructure-name/
    ├── main.tf
    ├── variables.tf
    ├── locals.tf
    ├── environments/
    │   ├── dev/
    │   │   └── dev.tfvars
    │   └── prod/
    │       └── prod.tfvars
    └── modules/
        ├── networking/
        ├── computing/          # Standard+ level
        ├── db/                 # Full level only
        ├── secrets/            # Full level only
        └── service/            # Full level only
```

### GitHub Workflows

#### NX Projects Workflow (`deploy-NX-projects.yaml`)
- Triggers on changes to `apps/**` and `libs/**`
- Identifies affected projects using NX
- Builds and deploys projects to ECS
- Supports matrix builds for multiple projects
- Integrates with AWS ECR and ECS

#### Terraform Workflow (`terraform-workflow.yaml`)
- Triggers on changes to `infrastructure/**`
- Supports multiple environments (dev/prod)
- Automated terraform plan and apply
- Retry logic for failed deployments
- AWS role assumption for secure access

#### Basic CI Workflow (`basic-ci.yaml`)
- Simple repository validation
- Runs on simple repository projects

#### Release Please Workflow (`release-please.yml`)
- Automated semantic versioning
- Changelog generation
- Release management

### Reusable GitHub Actions

#### NX-Specific Actions
- **nx-setup**: Sets up Node.js, pnpm, and NX workspace
- **identify-affected-proj**: Identifies changed NX projects
- **build-project**: Builds individual NX projects
- **build-push**: Builds and pushes Docker images to ECR

#### Infrastructure Actions
- **terraform-apply**: Runs Terraform init, plan, and apply
- **assume-role**: Assumes AWS IAM roles for deployment

#### Utility Actions
- **assume-role**: AWS role assumption with ECR login

## Customization

### Environment Variables
The generated workflows support these environment variables:

#### AWS Configuration
- `AWS_ACCOUNT_ID` - Your AWS account ID
- `AWS_HUB_ACCOUNT_ID` - Hub account for cross-account access
- `AWS_IAC_ACCOUNT_ID` - Infrastructure account ID
- `AWS_TERRAFORM_BUCKET` - S3 bucket for Terraform state
- `TERRAFORM_ENVIRONMENT` - Environment name (dev/prod)

#### GitHub Environments
The script automatically creates GitHub environments:
- **Development** - For dev branch deployments
- **Production** - For main branch deployments

### Terraform Customization
Update the generated Terraform files to match your requirements:

1. **Backend Configuration** - Update S3 bucket and region in `main.tf`
2. **Variables** - Modify `variables.tf` and environment `.tfvars` files
3. **Resources** - Customize module resources to your needs

### NX Workspace Customization
The generated NX workspace includes:
- Custom npm scripts for easy development
- Optimized build configurations
- Shared type libraries when both frontend and backend are created

## Best Practices

### Project Organization
- Use meaningful project names
- Follow consistent naming conventions
- Organize related projects under the same organization

### Infrastructure Management
- Use separate AWS accounts for different environments
- Store Terraform state in S3 with versioning enabled
- Use least-privilege IAM roles for deployments

### CI/CD Pipeline
- Test infrastructure changes in dev before prod
- Use matrix builds for efficient multi-project deployments
- Implement proper secret management

### Security
- Use GitHub environments for deployment protection
- Store sensitive data in AWS Secrets Manager
- Follow AWS security best practices

## Troubleshooting

### Common Issues

#### GitHub CLI Authentication
```bash
# Check authentication status
gh auth status

# Re-authenticate if needed
gh auth login
```

#### NX Workspace Issues
```bash
# Clear NX cache if build fails
npx nx reset

# Reinstall dependencies
npm install
```

#### Terraform Issues
```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan
```

### Getting Help
1. Check the generated README files in your project
2. Review GitHub Actions logs for deployment issues
3. Verify AWS permissions for infrastructure deployments
4. Ensure all prerequisites are installed and configured

## Contributing

This template generator is designed to be extensible. You can:

1. Add new project types by extending the batch script
2. Create additional GitHub Actions for specific use cases
3. Add new infrastructure modules for different cloud providers
4. Enhance the workflow templates for additional features

## License

This project template generator is provided as-is for educational and development purposes.
