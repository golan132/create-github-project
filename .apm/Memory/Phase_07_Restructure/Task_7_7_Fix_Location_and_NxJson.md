# Task 7.7: Fix Project Location & Nx.json (Regression)

**Goal**: Ensure the project is created in the correct location (`context.targetDirectory`) and `nx.json` is safely written.

**Status**: Completed

**Context**:
- User Complaint: "why is the project folder is rceated in the create-github-project folder?!"
- Error: `Failed to rewrite nx.json: ENOENT: no such file or directory`
- **Root Cause**: `NxWorkspaceGenerator` runs `create-nx-workspace` in `process.cwd()` (the tool's folder), but `utils/questions.ts` calculates the `targetDirectory` as a SIBLING folder. This mismatch means the directory at `targetDirectory` never exists, causing `fse.writeJson` to fail.

**Execution Steps**:
1.  **Modify `src/core/nx-generator.ts`**:
    -   In `initWorkspace`, locate the `execa` call that runs `create-nx-workspace`.
    -   Change its `cwd` from `process.cwd()` to `path.dirname(context.targetDirectory)`.
    -   In `ensureNxCompatibility`, assume the `targetDirectory` now correctly exists (due to step 1), but verify the `nxJsonPath` logic is solid.
2.  **Verify**:
    -   Run `npm run dev` with project name `loc-test`.
    -   **Expected Result**:
        -   `loc-test` folder is created as a SIBLING to `create-github-project` (e.g. `Projects/loc-test`).
        -   `nx.json` is successfully written.
        -   No `ENOENT` errors.
