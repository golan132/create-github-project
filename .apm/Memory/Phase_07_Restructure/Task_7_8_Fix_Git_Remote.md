# Task 7.8: Fix Git Remote Push & Personal Org

**Status**: Completed

**Goal**: Ensure specific handling for "personal" organization and ensure both main and dev branches are pushed to remote.

**Execution Steps**:
1.  [x] Modify `src/core/git-manager.ts`
    -   Fix `repoName` logic.
    -   Update push sequence.
2.  [x] Verify with `npx tsc --noEmit`.

**Defects Addressed**:
-   `setupRemote` fails for "personal" orgs (tries to create `personal/repo`). Fixed by checking for 'personal' string.
-   `setupRemote` only pushes current branch (dev), leaving main behind. Fixed by explicit `git push origin main` and `git push origin dev` calls.
