#!/usr/bin/env node
/**
 * Run BEFORE `expo run:android` to avoid the two most common Windows pain
 * points when targeting an Android emulator:
 *
 * 1. Stale `adb.exe` server with a mismatched protocol version (often
 *    spawned by a 3rd-party tool — Xiaomi/Samsung/HiSuite suites,
 *    BlueStacks, an older Android Studio, etc). Symptom:
 *
 *      adb server version (32) doesn't match this client (41); killing...
 *      adb.exe: device offline
 *
 *    Fix: kill any running `adb`, then explicitly (re)start the daemon
 *    using `$ANDROID_HOME/platform-tools/adb.exe` so the right binary
 *    owns port 5037.
 *
 * 2. Stale `*.lock` files left by a previously-crashed emulator instance
 *    that make a fresh launch fail with:
 *
 *      FATAL | Running multiple emulators with the same AVD is an
 *      experimental feature. Please use -read-only flag to enable this.
 *
 *    Fix: delete `*.lock` under every `%USERPROFILE%/.android/avd/*.avd/`.
 *
 * Safe to run repeatedly. No-op on non-Windows hosts for the lock-file
 * sweep when the AVD dir is missing.
 */
import { spawnSync } from 'node:child_process';
import * as fs from 'node:fs';
import * as os from 'node:os';
import * as path from 'node:path';

const isWindows = process.platform === 'win32';

const sdk = process.env['ANDROID_HOME'] || process.env['ANDROID_SDK_ROOT'];
if (!sdk) {
  console.warn('[android-preflight] ANDROID_HOME / ANDROID_SDK_ROOT not set — skipping adb reset.');
} else {
  const adb = path.join(sdk, 'platform-tools', isWindows ? 'adb.exe' : 'adb');
  if (!fs.existsSync(adb)) {
    console.warn(`[android-preflight] adb not found at ${adb} — skipping adb reset.`);
  } else {
    // 1. Kill ANY running adb (including a v32 ghost from another tool).
    if (isWindows) {
      spawnSync('taskkill', ['/F', '/IM', 'adb.exe'], { stdio: 'ignore' });
    } else {
      spawnSync('pkill', ['-9', '-x', 'adb'], { stdio: 'ignore' });
    }

    // 2. Restart the daemon using OUR adb so it owns port 5037.
    const kill = spawnSync(adb, ['kill-server'], { stdio: 'ignore' });
    const start = spawnSync(adb, ['start-server'], { stdio: 'inherit' });
    if (start.status === 0) {
      console.log('[android-preflight] adb server restarted from', adb);
    } else {
      console.warn('[android-preflight] adb start-server returned', start.status);
    }
  }
}

// 3. Clear stale AVD lock files.
const avdRoot = path.join(os.homedir(), '.android', 'avd');
if (fs.existsSync(avdRoot)) {
  let cleared = 0;
  for (const entry of fs.readdirSync(avdRoot, { withFileTypes: true })) {
    if (!entry.isDirectory() || !entry.name.endsWith('.avd')) continue;
    const avdDir = path.join(avdRoot, entry.name);
    for (const f of fs.readdirSync(avdDir)) {
      if (f.endsWith('.lock')) {
        try {
          fs.rmSync(path.join(avdDir, f), { recursive: true, force: true });
          cleared++;
        } catch {
          // ignore — file probably held open by a live emulator
        }
      }
    }
  }
  if (cleared > 0) {
    console.log(`[android-preflight] Cleared ${cleared} stale AVD lock file(s).`);
  }
}
