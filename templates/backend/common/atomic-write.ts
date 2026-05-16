import * as fs from 'node:fs';
import * as fsp from 'node:fs/promises';
import * as path from 'node:path';

/**
 * Per-target write queue. Each file path gets its own serialised promise
 * chain so concurrent writes to the same file can never interleave, while
 * writes to *different* files still run in parallel.
 */
const queues = new Map<string, Promise<void>>();

export async function atomicWriteJson(
  filePath: string,
  value: unknown,
  pretty = true,
): Promise<void> {
  const payload = pretty ? JSON.stringify(value, null, 2) : JSON.stringify(value);
  return atomicWriteText(filePath, payload);
}

export async function atomicWriteText(filePath: string, payload: string): Promise<void> {
  const next = (queues.get(filePath) ?? Promise.resolve()).then(async () => {
    const dir = path.dirname(filePath);
    await fsp.mkdir(dir, { recursive: true });
    const tmp = `${filePath}.${process.pid}.${Date.now()}.tmp`;
    await fsp.writeFile(tmp, payload, 'utf-8');
    await fsp.rename(tmp, filePath);
  });
  queues.set(
    filePath,
    next.catch(() => undefined),
  );
  return next;
}

/** Synchronous fallback for `process.on('exit', ...)` flushes. Avoid in hot paths. */
export function atomicWriteJsonSync(filePath: string, value: unknown): void {
  const payload = JSON.stringify(value, null, 2);
  const dir = path.dirname(filePath);
  fs.mkdirSync(dir, { recursive: true });
  const tmp = `${filePath}.${process.pid}.${Date.now()}.tmp`;
  fs.writeFileSync(tmp, payload, 'utf-8');
  fs.renameSync(tmp, filePath);
}
