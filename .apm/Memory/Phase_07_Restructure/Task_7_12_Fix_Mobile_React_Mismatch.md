# Task 7.12: Fix Mobile React Version Mismatch

**Status**: Completed
**Date**: 2026-02-05
**Agent**: Implementation Agent (GitHub Copilot)

## Problem
Users reported "Invalid hook call" errors in the Mobile App. This is a common issue in monorepos where the root `package.json` installs a newer version of React (e.g., v19) while Expo (used in the Mobile app) strictly requires React 18.2.0. This leads to multiple copies of React being loaded, breaking hooks.

## Solution implemented
Modified `src/core/dependency-manager.ts` inside the `installStandardStack` method.

### Changes:
- Added a check for `context.apps.mobile`.
- If mobile is enabled, the dependency manager now explicitly pushes the following packages to the installation list:
  - `react@18.2.0`
  - `react-dom@18.2.0`
  - `react-native@0.74.5`
- This forces `npm install` to resolve and pin these versions at the root level, ensuring alignment across the workspace and satisfying Expo's requirements.

## File Changes
- `src/core/dependency-manager.ts`: Added conditional logic to append pinned versions to `coreDeps`.

## Verification
- Code review confirms that `coreDeps` will include versioned packages `react@18.2.0`, `react-dom@18.2.0`, `react-native@0.74.5` when `context.apps.mobile` is true.
- `execa` will execute `npm install ... react@18.2.0 ...` which effectively pins the versions in `package.json` and `node_modules`.
