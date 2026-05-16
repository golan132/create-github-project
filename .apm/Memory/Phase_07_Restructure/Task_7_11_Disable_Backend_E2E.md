# Task 7.11: Disable E2E for Backend

- [x] Modify `src/core/nx-generator.ts`:
    - Added `'--e2eTestRunner=none'` to `generateBackend`.
- [x] Verify:
    - Code reviewed and modification confirmed.

The generator will now skip E2E test creation for the NestJS backend application.
