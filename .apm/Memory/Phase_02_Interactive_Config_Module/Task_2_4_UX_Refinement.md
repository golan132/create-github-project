---
agent: Agent_Featuredev
task_ref: "Task 2.4"
status: Completed
ad_hoc_delegation: false
compatibility_issues: false
important_findings: false
---
# Task Log: Task 2.4 - Refine Prompt UX

## Summary
Updated the CLI prompts in `src/prompts/questions.ts` to provide verbose, descriptive labels for "Project Type" and "Feature" selections. This ensures clarity for the end-user regarding what each option generates without requiring external documentation.

## Details
1.  **Project Type Descriptions**:
    *   Renamed `NX Workspace` -> `Enterprise Nx Monorepo (NestJS, React, Shared Libs)`
    *   Renamed `Full Stack` -> `Full Stack Platform (Nx Monorepo + Terraform Infra + GitHub Actions)`
    *   Renamed `Simple Git` -> `Simple Git Repository (Standard .gitignore + README)`
    *   Renamed `Terraform` -> `Terraform Infrastructure (Modules, Environments, Remote State)`
2.  **Feature Descriptions**:
    *   Updated `Shared Libraries` -> `Shared Libraries (Types, Utils, Enums - Enterprise Standards)`
3.  **Organization Descriptions**:
    *   Clarified `Personal` to `Personal Project (No Organization)`
    *   Clarified `Custom` to `Custom Organization (Enter Name manually)`

## Output
- `tools/scaffolder/src/prompts/questions.ts`: Updated prompt text.

## Issues
- User reported "open inputs" instead of list choices.
- **Root Cause**: `package.json` had `"type": "commonjs"` while using Pure ESM dependencies (`inquirer` v13+, `conf`, `chalk`).
- **Fix**: Updated `package.json` to `"type": "module"`. Verified CLI startup with `--help`.

## Next Steps
Proceed to **Phase 3: Deep Scaffolding Engine**.
