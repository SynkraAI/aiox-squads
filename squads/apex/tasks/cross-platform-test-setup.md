# Task: cross-platform-test-setup

```yaml
id: cross-platform-test-setup
version: "1.0.0"
title: "Cross-Platform Test Infrastructure Setup"
description: >
  Sets up cross-platform test infrastructure covering Playwright
  for web, Detox for iOS and Android, shared test scenarios,
  device farm/simulator configuration, CI matrix setup, and
  workflow documentation.
elicit: false
owner: qa-xplatform
executor: qa-xplatform
outputs:
  - Playwright web test configuration
  - Detox iOS/Android test configuration
  - Shared test scenario definitions
  - Device farm/simulator setup
  - CI matrix configuration
  - Test workflow documentation
```

---

## When This Task Runs

This task runs when:
- A cross-platform project needs E2E testing from scratch
- Testing exists for one platform but needs to be extended to others
- The team wants to ensure feature parity across web and native
- A new CI pipeline is being established for cross-platform testing
- `*xplatform-test-setup` or `*setup-cross-platform-tests` is invoked

This task does NOT run when:
- Only visual regression testing is needed (delegate to `@qa-visual`)
- Only web testing is needed (Playwright only, no native)
- Only a device matrix needs to be designed (use `device-matrix-design`)

---

## Execution Steps

### Step 1: Configure Playwright for Web

Set up Playwright as the web E2E testing framework.

**Installation and configuration:**
```bash
npm init playwright@latest
```

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e/web',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { open: 'never' }],
    ['junit', { outputFile: 'results/web-results.xml' }],
  ],
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'on-first-retry',
  },
  projects: [
    { name: 'chrome-desktop', use: { ...devices['Desktop Chrome'] } },
    { name: 'chrome-mobile', use: { ...devices['Pixel 5'] } },
    { name: 'safari-desktop', use: { ...devices['Desktop Safari'] } },
    { name: 'safari-mobile', use: { ...devices['iPhone 13'] } },
  ],
  webServer: {
    command: 'npm run start',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

**Web test structure:**
```
tests/e2e/
├── web/
│   ├── auth.spec.ts           # Login, logout, register
│   ├── navigation.spec.ts     # Page navigation, routing
│   ├── forms.spec.ts          # Form submission, validation
│   └── shared/                # Shared test utilities
│       ├── fixtures.ts
│       └── helpers.ts
├── shared/
│   ├── scenarios.ts           # Shared test scenarios (Step 3)
│   └── assertions.ts          # Platform-agnostic assertions
└── native/
    └── ...                    # Detox tests (Step 2)
```

**Output:** Playwright configuration and project structure.

### Step 2: Configure Detox for iOS/Android

Set up Detox for native mobile E2E testing.

**Installation:**
```bash
npm install detox --save-dev
npx detox init
```

**Configuration:**
```javascript
// .detoxrc.js
module.exports = {
  testRunner: {
    args: {
      config: 'tests/e2e/native/jest.config.js',
    },
  },
  apps: {
    'ios.debug': {
      type: 'ios.app',
      binaryPath: 'ios/build/Build/Products/Debug-iphonesimulator/MyApp.app',
      build: 'xcodebuild -workspace ios/MyApp.xcworkspace -scheme MyApp -configuration Debug -sdk iphonesimulator -derivedDataPath ios/build',
    },
    'ios.release': {
      type: 'ios.app',
      binaryPath: 'ios/build/Build/Products/Release-iphonesimulator/MyApp.app',
      build: 'xcodebuild -workspace ios/MyApp.xcworkspace -scheme MyApp -configuration Release -sdk iphonesimulator -derivedDataPath ios/build',
    },
    'android.debug': {
      type: 'android.apk',
      binaryPath: 'android/app/build/outputs/apk/debug/app-debug.apk',
      build: 'cd android && ./gradlew assembleDebug assembleAndroidTest -DtestBuildType=debug',
      reversePorts: [8081],
    },
    'android.release': {
      type: 'android.apk',
      binaryPath: 'android/app/build/outputs/apk/release/app-release.apk',
      build: 'cd android && ./gradlew assembleRelease assembleAndroidTest -DtestBuildType=release',
    },
  },
  devices: {
    simulator: {
      type: 'ios.simulator',
      device: { type: 'iPhone 15' },
    },
    emulator: {
      type: 'android.emulator',
      device: { avdName: 'Pixel_6_API_34' },
    },
  },
  configurations: {
    'ios.sim.debug': { device: 'simulator', app: 'ios.debug' },
    'ios.sim.release': { device: 'simulator', app: 'ios.release' },
    'android.emu.debug': { device: 'emulator', app: 'android.debug' },
    'android.emu.release': { device: 'emulator', app: 'android.release' },
  },
};
```

**Detox test example:**
```typescript
// tests/e2e/native/auth.test.ts
describe('Authentication', () => {
  beforeAll(async () => {
    await device.launchApp({ newInstance: true });
  });

  it('should login with valid credentials', async () => {
    await element(by.id('email-input')).typeText('user@test.com');
    await element(by.id('password-input')).typeText('password123');
    await element(by.id('login-button')).tap();
    await expect(element(by.id('dashboard-screen'))).toBeVisible();
  });
});
```

**Output:** Detox configuration for iOS and Android.

### Step 3: Define Shared Test Scenarios

Create platform-agnostic test scenario definitions that both Playwright and Detox implement.

**Shared scenario format:**
```typescript
// tests/e2e/shared/scenarios.ts
export const authScenarios = {
  login: {
    name: 'User can log in with valid credentials',
    preconditions: ['user exists in database'],
    steps: [
      { action: 'enterText', target: 'email-input', value: 'user@test.com' },
      { action: 'enterText', target: 'password-input', value: 'password123' },
      { action: 'tap', target: 'login-button' },
    ],
    assertions: [
      { type: 'visible', target: 'dashboard-screen' },
      { type: 'notVisible', target: 'login-screen' },
    ],
  },
  loginInvalidPassword: {
    name: 'User sees error with invalid password',
    preconditions: ['user exists in database'],
    steps: [
      { action: 'enterText', target: 'email-input', value: 'user@test.com' },
      { action: 'enterText', target: 'password-input', value: 'wrong' },
      { action: 'tap', target: 'login-button' },
    ],
    assertions: [
      { type: 'visible', target: 'error-message' },
      { type: 'textContains', target: 'error-message', value: 'Invalid' },
    ],
  },
};
```

**Platform implementations reference the same scenarios:**
```typescript
// Web (Playwright)
test(authScenarios.login.name, async ({ page }) => {
  await page.getByTestId('email-input').fill('user@test.com');
  await page.getByTestId('password-input').fill('password123');
  await page.getByTestId('login-button').click();
  await expect(page.getByTestId('dashboard-screen')).toBeVisible();
});

// Native (Detox)
it(authScenarios.login.name, async () => {
  await element(by.id('email-input')).typeText('user@test.com');
  await element(by.id('password-input')).typeText('password123');
  await element(by.id('login-button')).tap();
  await expect(element(by.id('dashboard-screen'))).toBeVisible();
});
```

**Output:** Shared test scenarios covering all critical user flows.

### Step 4: Set Up Device Farm/Simulators

Configure the device and simulator infrastructure for testing.

**Local simulators:**
```bash
# iOS Simulator (macOS only)
xcrun simctl list devices
xcrun simctl create "iPhone 15" com.apple.CoreSimulator.SimDeviceType.iPhone-15

# Android Emulator
sdkmanager "system-images;android-34;google_apis;arm64-v8a"
avdmanager create avd -n Pixel_6_API_34 -k "system-images;android-34;google_apis;arm64-v8a"
```

**Cloud device farms (for CI):**

| Service | Strengths | Use For |
|---------|-----------|---------|
| BrowserStack | Real devices, wide device range | Comprehensive device testing |
| AWS Device Farm | AWS integration, real devices | AWS-native CI pipelines |
| Firebase Test Lab | Android focus, Google integration | Android-heavy projects |
| Sauce Labs | Cross-browser + mobile | Enterprise testing |

**Local development setup:**
- iOS: Xcode Simulator (fast, free, macOS only)
- Android: Android Studio Emulator (cross-platform)
- Web: Playwright browsers (fast, headless capable)

**Output:** Device infrastructure configuration.

### Step 5: Configure CI Matrix

Set up CI to run tests across all platform and device combinations.

**GitHub Actions matrix:**
```yaml
name: Cross-Platform E2E Tests

on:
  pull_request:
    branches: [main]

jobs:
  web-tests:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        browser: [chromium, firefox, webkit]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npx playwright install --with-deps ${{ matrix.browser }}
      - run: npx playwright test --project=${{ matrix.browser }}
      - uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: web-results-${{ matrix.browser }}
          path: test-results/

  ios-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npx detox build --configuration ios.sim.release
      - run: npx detox test --configuration ios.sim.release --cleanup

  android-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          java-version: '17'
      - uses: actions/setup-node@v4
      - run: npm ci
      - name: Start Android Emulator
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 34
          script: npx detox test --configuration android.emu.release
```

**CI optimization:**
- Run web tests first (fastest) — fail fast
- Run iOS and Android in parallel
- Use release builds for CI (faster execution)
- Cache node_modules and build artifacts
- Upload screenshots and videos on failure

**Output:** CI matrix configuration for all platforms.

### Step 6: Document Test Workflow

Create comprehensive documentation for the cross-platform testing workflow.

**Developer workflow:**
```
1. Write shared scenario in tests/e2e/shared/
2. Implement web test in tests/e2e/web/
3. Implement native test in tests/e2e/native/
4. Run locally:
   - Web: npx playwright test
   - iOS: npx detox test -c ios.sim.debug
   - Android: npx detox test -c android.emu.debug
5. Push — CI runs all platforms
6. Fix any platform-specific failures
```

**Test naming convention:**
- Use the same test name across all platforms (from shared scenario)
- Prefix test IDs with platform: `web.auth.login`, `ios.auth.login`, `android.auth.login`

**Adding new tests:**
1. Define the scenario in shared format
2. Implement for web (Playwright)
3. Implement for native (Detox)
4. Verify all pass locally
5. Verify CI matrix passes

**Output:** Cross-platform test workflow documentation.

---

## Quality Criteria

- Web tests must cover Chrome, Safari, and Firefox
- Native tests must cover iOS and Android
- Shared scenarios must exist for all critical user flows
- CI must run all platform tests on every PR
- Test failures must include screenshots/videos for debugging
- The same test scenarios must be implemented across all platforms

---

*Squad Apex — Cross-Platform Test Infrastructure Setup Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-cross-platform-test-setup
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Web tests must cover Chrome, Safari, and Firefox"
    - "Native tests must cover iOS and Android via Detox"
    - "Shared test scenarios must exist for all critical user flows"
    - "CI must run all platform tests on every PR with failure artifacts (screenshots/videos)"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Playwright web test config, Detox iOS/Android config, shared test scenarios, device farm/simulator setup, CI matrix configuration, and test workflow documentation |
| Next action | Coordinate CI pipeline integration with `@devops` and begin writing test scenarios per feature |
