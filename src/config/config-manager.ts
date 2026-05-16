import Conf from 'conf';

export interface ScaffolderConfig {
  defaultOrganization?: string;
  defaultAuthor?: string;
}

export class ConfigManager {
  private conf: Conf<ScaffolderConfig>;

  constructor() {
    this.conf = new Conf<ScaffolderConfig>({
      projectName: 'apm-scaffolder',
      defaults: {}
    });
  }

  public get<K extends keyof ScaffolderConfig>(key: K): ScaffolderConfig[K] {
    return this.conf.get(key);
  }

  public set<K extends keyof ScaffolderConfig>(key: K, value: ScaffolderConfig[K]): void {
    this.conf.set(key, value);
  }

  public clear(): void {
    this.conf.clear();
  }

  public getAll(): ScaffolderConfig {
    return this.conf.store;
  }
}
