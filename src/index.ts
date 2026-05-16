#!/usr/bin/env node
import { Command } from 'commander';
import { execa } from 'execa';
import fse from 'fs-extra';
import { ConfigManager } from './config/config-manager.js';
import { BackendTemplateApplier } from './core/backend-template-applier.js';
import { DependencyManager } from './core/dependency-manager.js';
import { GitManager } from './core/git-manager.js';
import { NxWorkspaceGenerator } from './core/nx-generator.js';
import { TemplateManager } from './core/template-manager.js';
import { promptUser } from './prompts/questions.js';
import { Logger } from './utils/logger.js';

const program = new Command();

program
  .name('apm-scaffolder')
  .description('CLI tool for scaffolding Enterprise Nx Workspaces')
  .version('0.0.1')
  .option('-d, --debug', 'Enable debug mode (disable cleanup)', false)
  .option('-v, --verbose', 'Enable verbose logging', false)
  .option('-l, --location <path>', 'Custom target parent directory path')
  .action(async (options) => {
    // Initialize Logger based on verbose flag
    if (options.verbose) {
      Logger.setVerbose(true);
    }

    await Logger.info('APM Scaffolder CLI Initialized');
    await Logger.debug(`Options received: ${JSON.stringify(options)}`);
    
    if (options.debug) {
      await Logger.warn('Debug mode enabled - cleanup will be skipped on error.');
    }

 let scaffoldContext;
    try {
      const configManager = new ConfigManager();
      await Logger.debug('ConfigManager initialized');

      scaffoldContext = await promptUser(configManager, { location: options.location });
      
      await Logger.success('Configuration completed successfully!');
      await Logger.info('Build Context:');
      console.log(JSON.stringify(scaffoldContext, null, 2));

      // Phase 3: Deep Scaffolding Engine
      const nxGenerator = new NxWorkspaceGenerator();
      await nxGenerator.initWorkspace(scaffoldContext);
      
      // Phase 4: Asset Integration & Dependencies
      const templateManager = new TemplateManager();
      await templateManager.copyAssets(scaffoldContext);

      const backendApplier = new BackendTemplateApplier();
      await backendApplier.apply(scaffoldContext);

      const dependencyManager = new DependencyManager();
      await dependencyManager.installStandardStack(scaffoldContext);
      await dependencyManager.addConvenienceScripts(scaffoldContext);

      // Phase 5: Git Integration & Finalization
      const gitManager = new GitManager();
      await gitManager.init(scaffoldContext);
      await gitManager.setupRemote(scaffoldContext);

      await Logger.success('==================================================');
      await Logger.success('   Project Setup Complete!                        ');
      await Logger.success('==================================================');
      await Logger.info(`Project location: ${scaffoldContext.targetDirectory}`);

      if (scaffoldContext.apps.mobile) {
        const m = `${scaffoldContext.projectName}-mobile`;
        await Logger.info('');
        await Logger.info('Mobile app — first time setup:');
        await Logger.info('  npm run mobile:start             # Metro + QR for Expo Go (real device)');
        await Logger.info('  npm run mobile:web               # Open the app in your browser');
        await Logger.info('  npm run mobile:prebuild          # Generate native android/ + ios/ folders');
        await Logger.info('  npm run mobile:android-sdk       # (Windows) write android/local.properties from $env:ANDROID_HOME');
        await Logger.info(`  npm run mobile:android           # Preflight adb + build APK + install on emulator (\`nx run ${m}:run-android\`)`);
        await Logger.info('  npm run mobile:install           # Re-align Expo SDK versions after upgrade');
        await Logger.info('');
        await Logger.info('Tip: on Windows, set ANDROID_HOME *for this shell* with:');
        await Logger.info('  $env:ANDROID_HOME = "C:\\Users\\<you>\\AppData\\Local\\Android\\Sdk"');
        await Logger.info('  (a per-User registry value via [Environment]::SetEnvironmentVariable() requires a terminal restart)');
      }

      // Attempt to launch VS Code
      try {
        await execa('code', ['.'], { cwd: scaffoldContext.targetDirectory });
      } catch (e) {
        await Logger.warn('Could not launch VS Code (code command not found).');
      }

    } catch (error) {
      await Logger.error(`An error occurred: ${(error as Error).message}`);
      
      if (!options.debug && scaffoldContext?.targetDirectory) {
         await Logger.info('Cleaning up failed directory...');
         await fse.remove(scaffoldContext.targetDirectory);
         await Logger.success('Cleanup complete.');
      } else {
         await Logger.warn('Snapshot preserved (Debug Mode or Cleanup failed).');
      }
      
      process.exit(1);
    }
  });

program.parse(process.argv);
