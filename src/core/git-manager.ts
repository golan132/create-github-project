import { execa } from 'execa';
import { ScaffoldContext } from '../types/scaffold-context.js';
import { Logger } from '../utils/logger.js';

export class GitManager {
  async init(context: ScaffoldContext): Promise<void> {
    await Logger.info('Initializing Git repository...');
    
    try {
      // Initialize Git
      await execa('git', ['init'], { cwd: context.targetDirectory });
      
      // Ensure branch is main
      await execa('git', ['branch', '-M', 'main'], { cwd: context.targetDirectory });
      
      // Add all files
      await execa('git', ['add', '.'], { cwd: context.targetDirectory });
      
      // Initial commit
      await execa('git', ['commit', '-m', 'chore: initial commit from apm-scaffolder'], { 
        cwd: context.targetDirectory 
      });
      
      await Logger.success('Git repository initialized and initial commit created.');

      // Create and switch to dev branch
      await Logger.info('Creating development branch...');
      await execa('git', ['checkout', '-b', 'dev'], { cwd: context.targetDirectory });
      await Logger.success('Switched to new branch: dev');

    } catch (error) {
       await Logger.error(`Git initialization failed: ${(error as Error).message}`);
       // We don't throw here to allow the process to finish even if Git fails? 
       // Re-reading instructions: "Step 2: Implement Error Handling... Wrap the entire logic"
       // If Git fails, it's usually critical enough to throw, but let's throw to trigger cleanup if strictly required
       throw error;
    }
  }

  async setupRemote(context: ScaffoldContext): Promise<void> {
    try {
      // Check if gh is installed
      await execa('gh', ['--version']);
      
      // Check auth status
      await execa('gh', ['auth', 'status']);
      
      await Logger.info('GitHub CLI detected and authenticated. Creating remote repository...');

      // Use repoName (which preserves the casing the user typed) so the
      // GitHub repo can be e.g. "Novatrade" while the local Nx workspace
      // folder is "novatrade".
      const repoName = context.organization === 'personal'
        ? context.repoName
        : `${context.organization}/${context.repoName}`;

      // gh repo create <org>/<name> --private --source=. --remote=origin
      // We remove --push to manually push branches in order
      await execa('gh', [
        'repo', 'create', 
        repoName,
        '--private',
        '--source=.',
        '--remote=origin'
      ], { cwd: context.targetDirectory });

      await Logger.success(`GitHub repository created: https://github.com/${repoName}`);

      // Push main branch
      await Logger.info('Pushing main branch...');
      try {
        await execa('git', ['push', '-u', 'origin', 'main'], { cwd: context.targetDirectory });
      } catch (pushError) {
        await Logger.warn(`Failed to push main branch: ${(pushError as Error).message}`);
      }

      // Push dev branch
      await Logger.info('Pushing dev branch...');
      try {
        await execa('git', ['push', '-u', 'origin', 'dev'], { cwd: context.targetDirectory });
      } catch (pushError) {
        await Logger.warn(`Failed to push dev branch: ${(pushError as Error).message}`);
      }

    } catch (error) {
      // Best effort — do not fail the whole scaffold. Surface the actual
      // gh stderr so the user can see *why* (auth, repo exists, network,
      // org permissions, etc.) instead of the generic catch-all message.
      const err = error as { stderr?: string; stdout?: string; message: string };
      const detail = (err.stderr || err.stdout || err.message || '').trim();
      await Logger.warn('Skipping GitHub remote creation. Details:');
      for (const line of detail.split(/\r?\n/).filter(Boolean)) {
        await Logger.warn(`  ${line}`);
      }
    }
  }
}
