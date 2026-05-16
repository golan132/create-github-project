import chalk from 'chalk';
import fse from 'fs-extra';
import * as path from 'path';

export type LogLevel = 'info' | 'success' | 'warn' | 'error' | 'debug';

export class Logger {
  private static isVerbose = false;
  private static logFilePath = path.resolve(process.cwd(), '../../setup_log.txt');

  public static setVerbose(verbose: boolean) {
    this.isVerbose = verbose;
    this.debug(`Verbose mode enabled: ${verbose}`);
    this.debug(`Log file path: ${this.logFilePath}`);
  }

  private static formatMessage(level: LogLevel, message: string): string {
    const timestamp = new Date().toISOString();
    return `[${timestamp}] [${level.toUpperCase()}] ${message}`;
  }

  private static async appendToLogFile(message: string) {
    try {
      await fse.ensureFile(this.logFilePath);
      await fse.appendFile(this.logFilePath, message + '\n');
    } catch (error) {
       // Fallback to console if file logging fails, but don't loop endlessly
       console.error(chalk.red(`Failed to write to log file: ${(error as Error).message}`));
    }
  }

  public static async log(level: LogLevel, message: string) {
    const formattedMessage = this.formatMessage(level, message);
    
    // Write to file (always)
    await this.appendToLogFile(formattedMessage);

    // Console output logic
    switch (level) {
      case 'info':
        console.log(chalk.blue(message));
        break;
      case 'success':
        console.log(chalk.green(message));
        break;
      case 'warn':
        console.warn(chalk.yellow(message));
        break;
      case 'error':
        console.error(chalk.red(message));
        break;
      case 'debug':
        if (this.isVerbose) {
          console.log(chalk.gray(message));
        }
        break;
    }
  }

  public static info(message: string) { return this.log('info', message); }
  public static success(message: string) { return this.log('success', message); }
  public static warn(message: string) { return this.log('warn', message); }
  public static error(message: string) { return this.log('error', message); }
  public static debug(message: string) { return this.log('debug', message); }
}
