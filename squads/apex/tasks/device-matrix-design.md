# Task: device-matrix-design

```yaml
id: device-matrix-design
version: "1.0.0"
title: "Device Test Matrix Design"
description: >
  Designs the device testing matrix by defining target devices
  across flagship, mid-range, and budget tiers, mapping OS versions,
  defining browser versions for web, prioritizing by user analytics,
  creating a test schedule, and documenting the complete matrix.
elicit: false
owner: qa-xplatform
executor: qa-xplatform
outputs:
  - Device tier definitions (flagship, mid-range, budget)
  - OS version coverage map
  - Browser version matrix for web
  - Analytics-based prioritization
  - Test schedule
  - Device matrix documentation
```

---

## When This Task Runs

This task runs when:
- A new product is establishing its device support strategy
- The existing device matrix is outdated and needs refreshing
- Analytics reveal device distribution changes
- Users report issues on specific devices not in the test matrix
- `*device-matrix` or `*design-device-matrix` is invoked

This task does NOT run when:
- Test infrastructure needs setup (use `cross-platform-test-setup`)
- Only gesture testing is needed on existing devices (use `gesture-test-suite`)
- The task is about visual regression (delegate to `@qa-visual`)

---

## Execution Steps

### Step 1: Define Target Devices

Select representative devices across performance tiers.

**iOS devices:**

| Tier | Device | Chip | RAM | Screen | Released |
|------|--------|------|-----|--------|----------|
| Flagship | iPhone 15 Pro Max | A17 Pro | 8GB | 6.7" 120Hz | 2023 |
| Flagship | iPhone 15 | A16 | 6GB | 6.1" 60Hz | 2023 |
| Mid-range | iPhone 13 | A15 | 4GB | 6.1" 60Hz | 2021 |
| Budget | iPhone SE (3rd) | A15 | 4GB | 4.7" 60Hz | 2022 |
| Tablet | iPad Air (5th) | M1 | 8GB | 10.9" 60Hz | 2022 |
| Tablet | iPad mini (6th) | A15 | 4GB | 8.3" 60Hz | 2021 |

**Android devices:**

| Tier | Device | Chip | RAM | Screen | Released |
|------|--------|------|-----|--------|----------|
| Flagship | Samsung Galaxy S24 Ultra | Snapdragon 8 Gen 3 | 12GB | 6.8" 120Hz | 2024 |
| Flagship | Google Pixel 8 Pro | Tensor G3 | 12GB | 6.7" 120Hz | 2023 |
| Mid-range | Samsung Galaxy A54 | Exynos 1380 | 8GB | 6.4" 120Hz | 2023 |
| Mid-range | Google Pixel 6a | Tensor G1 | 6GB | 6.1" 60Hz | 2022 |
| Budget | Samsung Galaxy A14 | Helio G80 | 4GB | 6.6" 60Hz | 2023 |
| Budget | Xiaomi Redmi Note 12 | Snapdragon 685 | 4GB | 6.67" 120Hz | 2023 |
| Tablet | Samsung Galaxy Tab S9 | Snapdragon 8 Gen 2 | 8GB | 11" 120Hz | 2023 |

**Selection criteria:**
- At least one flagship per OS (best-case performance)
- At least one mid-range per OS (typical user experience)
- At least one budget per OS (worst-case performance — the real test)
- At least one small screen (iPhone SE) for layout constraints
- At least one tablet per OS for responsive layout validation

**Output:** Device list by tier with specifications.

### Step 2: Map OS Versions to Test

Define the minimum and maximum OS versions supported and tested.

**iOS version coverage:**

| iOS Version | Support Level | Test Priority | Notes |
|-------------|-------------|---------------|-------|
| iOS 17.x | Full support | High | Current |
| iOS 16.x | Full support | High | Previous major |
| iOS 15.x | Degraded (no new features) | Medium | 2 versions back |
| iOS 14.x | Not supported | None | EOL |

**Android version coverage:**

| Android Version | API Level | Support Level | Test Priority |
|----------------|-----------|---------------|---------------|
| Android 14 (U) | 34 | Full support | High |
| Android 13 (T) | 33 | Full support | High |
| Android 12 (S) | 31-32 | Full support | Medium |
| Android 11 (R) | 30 | Degraded | Low |
| Android 10 (Q) | 29 | Not supported | None |

**OS version selection rationale:**
- Support the last 2-3 major versions (covers 90%+ of users)
- Check actual user distribution via analytics
- New features may require the latest OS only (progressive enhancement)
- Security patches are only available on supported OS versions

**Output:** OS version support matrix.

### Step 3: Define Browser Versions for Web

Map browser versions to test for the web application.

**Desktop browsers:**

| Browser | Versions | Engine | Priority |
|---------|----------|--------|----------|
| Chrome | Latest, Latest-1 | Blink | High |
| Safari | Latest, Latest-1 | WebKit | High |
| Firefox | Latest, Latest-1 | Gecko | Medium |
| Edge | Latest | Blink | Low (Chrome-like) |

**Mobile browsers:**

| Browser | Platform | Versions | Priority |
|---------|----------|----------|----------|
| Safari | iOS | Matches iOS version | High |
| Chrome | Android | Latest, Latest-1 | High |
| Samsung Internet | Android | Latest | Medium |
| Firefox | Android | Latest | Low |

**Browser + OS combinations:**

| Combination | Priority | Why |
|-------------|----------|-----|
| Chrome + Windows 10/11 | High | Most common desktop |
| Safari + macOS Sonoma/Ventura | High | Mac users |
| Safari + iOS 17/16 | High | Most common mobile |
| Chrome + Android 14/13 | High | Android mobile |
| Firefox + Windows/macOS | Medium | Independent engine |
| Edge + Windows | Low | Chromium-based |

**Output:** Browser version matrix.

### Step 4: Prioritize by User Analytics

Use actual user data to prioritize the device/browser/OS matrix.

**Data sources:**
- Google Analytics → Device category, OS, browser, screen resolution
- Firebase Analytics → Device model, OS version
- App Store/Play Console → Device distribution for native app users

**Prioritization framework:**
| User Percentage | Priority | Testing Frequency |
|----------------|----------|-------------------|
| > 20% | Critical | Every PR |
| 10-20% | High | Every release |
| 5-10% | Medium | Monthly |
| 1-5% | Low | Quarterly |
| < 1% | None | Not tested |

**Example analytics-driven matrix:**
```
Device/Browser Distribution:
1. iPhone (Safari) — 35% → CRITICAL
2. Android (Chrome) — 28% → CRITICAL
3. Desktop (Chrome) — 20% → CRITICAL
4. Desktop (Safari) — 8% → HIGH
5. Desktop (Firefox) — 4% → MEDIUM
6. iPad (Safari) — 3% → LOW
7. Samsung Internet — 2% → LOW
```

**Adjust matrix based on analytics:**
- If 90% of Android users are on Samsung, add more Samsung devices
- If most iOS users are on iPhone 13+, de-prioritize iPhone SE testing
- If Firefox usage is < 2%, reduce to quarterly testing
- If tablet usage is significant (> 5%), add dedicated tablet testing

**Output:** Analytics-prioritized device matrix.

### Step 5: Create Test Schedule

Define when each device/browser combination is tested.

**Testing cadence:**

| Cadence | Scope | Devices |
|---------|-------|---------|
| Every PR | Core flow smoke test | 1 iOS simulator, 1 Android emulator, 3 web browsers |
| Pre-release | Full regression suite | All Critical + High priority devices |
| Monthly | Extended device testing | All devices including Medium priority |
| Quarterly | Full matrix | All devices including Low priority + edge cases |

**PR testing (fast, focused):**
```
Time budget: 15 minutes
- Web: Chrome desktop + Chrome mobile (Playwright)
- iOS: iPhone 15 simulator (Detox)
- Android: Pixel 6 emulator (Detox)
- Scope: Critical user flows only (login, main feature, checkout)
```

**Pre-release testing (comprehensive):**
```
Time budget: 2 hours
- Web: Chrome, Safari, Firefox (desktop + mobile viewports)
- iOS: iPhone 15 Pro + iPhone SE + iPad Air (simulators + 1 real device)
- Android: Galaxy S24 + Pixel 6a + Galaxy A14 (emulators + 1 real device)
- Scope: Full regression suite + visual regression
```

**Monthly extended testing:**
```
Time budget: 4 hours
- All of pre-release plus:
- Samsung Internet on Galaxy devices
- Older OS versions (iOS 16, Android 12)
- Accessibility testing on each platform
- Performance profiling on budget devices
```

**Output:** Test schedule with time budgets and device assignments.

### Step 6: Document Matrix

Create the definitive device matrix document.

**Matrix document includes:**
- Complete device list with specifications
- OS version support table
- Browser support table
- Priority assignments with rationale
- Test schedule and cadence
- How to request adding a new device
- How to retire a device from the matrix
- Annual review schedule

**Annual review triggers:**
- New major OS release (iOS/Android)
- New device generation launch
- Significant shift in analytics distribution
- New browser engine version

**Output:** Complete device matrix documentation.

---

## Quality Criteria

- The matrix must include at least one device per performance tier (flagship, mid-range, budget)
- OS version coverage must cover 90%+ of the user base
- Prioritization must be based on actual analytics data, not assumptions
- The test schedule must have defined cadences with time budgets
- The matrix must be reviewed and updated at least annually
- Budget devices must be included (they reveal performance issues flagships hide)

---

*Squad Apex — Device Test Matrix Design Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-device-matrix-design
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Matrix must include at least one device per performance tier (flagship, mid-range, budget)"
    - "OS version coverage must cover 90%+ of the user base based on analytics"
    - "Prioritization must be based on actual analytics data, not assumptions"
    - "Test schedule must have defined cadences with time budgets per testing level"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Device tier definitions, OS version coverage map, browser version matrix, analytics-based prioritization, test schedule, and device matrix documentation |
| Next action | Feed device matrix into `cross-platform-test-setup` for CI configuration and distribute to all QA agents |
