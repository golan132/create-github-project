# Task 7.10: Fix Desktop Generator Logic

**Goal**: Resolve the `nx-electron` failure and suppress interactive prompts during the fallback generation.

**Status**: Completed

**Root Cause**:
1. `nx-electron` ran unconditionally or with incorrect flags, prompting for inputs and failing when the frontend project was missing.
2. The fallback React generator lacked explicit flags, causing it to prompt for style, routing, etc.

**Plan**:
1.  **Modify `src/core/nx-generator.ts`**:
    -   In `generateDesktop`:
        -   **Logic Check**: Only attempt `nx-electron` **IF** `context.apps.react` is `true`.
        -   **Flag Fix**: Use `--frontend-project` (kebab-case) instead of `--frontendProject`.
        -   **Fallback Improvement**: Update the fallback `nx g @nx/react:app` command to include:
            -   `--style=css`
            -   `--routing=false`
            -   `--e2eTestRunner=none`
            -   `--skipFormat`
    -   If `context.apps.react` is false, log a specific message and proceed to React generation.
    -   *Implemented*.
2.  **Verify**:
    -   Run `npm run dev` with project `desk-fix`. Select "Desktop".
