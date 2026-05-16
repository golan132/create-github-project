#!/usr/bin/env node
/**
 * Write `apps/mobile/<MOBILE_APP>/android/local.properties` pointing at the
 * Android SDK on this machine. This lets Gradle find the SDK without needing
 * `ANDROID_HOME` to be exported in the *current* shell — a common Windows
 * footgun where `[Environment]::SetEnvironmentVariable(..., 'User')` does
 * not affect the running PowerShell session until restart.
 *
 * Usage:  node tools/scripts/write-android-local-properties.mjs <mobile-app-name>
 *
 * If the script is invoked through `npm run mobile:android-sdk`, the
 * generator wires the app name as $npm_package_config_mobileAppName and we
 * fall back to it when no CLI arg is given.
 */
import * as fs from 'node:fs';
import * as path from 'node:path';

const appName = process.argv[2] || process.env['npm_package_config_mobileAppName'];
if (!appName) {
  console.error('Usage: node write-android-local-properties.mjs <mobile-app-name>');
  process.exit(1);
}

const sdk = process.env['ANDROID_HOME'] || process.env['ANDROID_SDK_ROOT'];
if (!sdk) {
  console.error('ANDROID_HOME / ANDROID_SDK_ROOT is not set.');
  console.error('Install Android Studio and set ANDROID_HOME to e.g.');
  console.error('  C:\\\\Users\\\\<you>\\\\AppData\\\\Local\\\\Android\\\\Sdk   (Windows)');
  console.error('  ~/Library/Android/sdk                                       (macOS)');
  console.error('  ~/Android/Sdk                                               (Linux)');
  process.exit(1);
}

const androidDir = path.join('apps', 'mobile', appName, 'android');
if (!fs.existsSync(androidDir)) {
  console.error(`No native android/ folder at ${androidDir}.`);
  console.error(`Run \`npm run mobile:prebuild\` first to generate it.`);
  process.exit(1);
}

// Gradle's local.properties is a Java .properties file: backslashes and
// colons must be escaped.
const escaped = sdk.replace(/\\/g, '\\\\').replace(/:/g, '\\:');
const target = path.join(androidDir, 'local.properties');
fs.writeFileSync(target, `sdk.dir=${escaped}\n`, 'utf-8');
console.log(`Wrote ${target}`);
console.log(`  sdk.dir=${escaped}`);
