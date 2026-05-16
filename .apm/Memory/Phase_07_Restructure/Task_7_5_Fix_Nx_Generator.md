# Task 7.5: Fix Nx Generator Error

## Status
- [x] Investigate cause of `Cannot read properties of null (reading 'useInferencePlugins')`
- [x] Fix `NxWorkspaceGenerator` to patch `nx.json`
- [x] Verify compilation

## Findings
The error occurs because `create-nx-workspace --preset=apps` with `--skipGit=true` generates a minimal `nx.json`. Subsequent installation of `@nx/js` (v20+) and running `nx g @nx/js:lib` triggers internal logic that expects `useInferencePlugins` to be readable or defined in the configuration, or expects a `plugins` array.

## Fix
Implemented `ensureNxCompatibility` in `src/core/nx-generator.ts`. 
This method:
1. Reads `nx.json` immediately after workspace creation.
2. Sets `useInferencePlugins: false` to prevent the crash and ensure deterministic behavior for the generator.
3. Initializes `plugins: []` if missing.
4. Writes the patched config back to disk before any generator commands run.

## Verification
- Code compiles with `tsc --noEmit`.
- Logic flow: Create Workspace -> Patch Config -> Install Plugin -> Generate Libs. This ensures the environment is valid before the plugin runs.
