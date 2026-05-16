# Task 7.3: Template Copying Refinement

## Status: Complete

## Changes
- **File**: `src/core/template-manager.ts`
- **Path Resolution**: Updated `repoRoot` from `path.resolve(__dirname, '../../../../')` to `path.resolve(__dirname, '../../')` to reflect the new flattened structure (`src/core`).
- **Exclusions**: Updated `fse.copy` filter logic to be robust:
    - Normalizes paths to use forward slashes.
    - Strictly checks for `/.git/` directory to avoid accidentally excluding `.github` (which contains the substring ".git").
    - Explicitly excludes `.github/prompts`.
    - Excludes `node_modules`.

## Verification
- Code review confirms `repoRoot` resolves to the workspace root given `__dirname` is `src/core`.
- `filter` function correctly checks for `.github/prompts` substring in normalized path.
