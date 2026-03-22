# Task: apex-ship-flow

```yaml
id: apex-ship-flow
version: "1.0.0"
title: "Apex Ship Flow"
description: >
  Final validation before merge. Runs visual regression across all breakpoints
  and themes, cross-platform device tests, and apex-lead final visual review.
  Produces an APPROVED or BLOCKED verdict. Nothing merges without APPROVED.
elicit: false
owner: apex-lead
agents:
  qa_visual: qa-visual
  qa_xplatform: qa-xplatform
  final_review: apex-lead
quality_gates:
  - QG-AX-008
  - QG-AX-009
  - QG-AX-010
requires:
  - apex-build-flow outputs (QG-AX-003 through QG-AX-007 must all be PASSED)
outputs:
  - Ship verdict: APPROVED | BLOCKED
  - Visual regression report
  - Cross-platform test report
  - Final review notes
```

---

## Inputs

This task requires all five quality gates from `apex-build-flow` to have passed:

| Input | Source | Required |
|-------|--------|----------|
| Implemented components | apex-build-flow | Yes |
| QG-AX-003 verdict | apex-build-flow | PASS required |
| QG-AX-004 verdict | apex-build-flow | PASS required |
| QG-AX-005 verdict | apex-build-flow | PASS required |
| QG-AX-006 verdict | apex-build-flow | PASS required |
| QG-AX-007 verdict | apex-build-flow | PASS required |
| Storybook stories | apex-build-flow | Yes |
| Target platforms | config / story | Yes |

If any build-flow gate has not passed, BLOCK and return to `apex-build-flow`.

---

## Execution

### Step 1 — Visual Regression (@qa-visual)

**Agent:** Andy (qa-visual)
**Input:** Implemented components + Storybook stories
**Deliverable:** Visual regression report

Andy runs visual regression testing to ensure the implementation matches the approved
design spec pixel-for-pixel and introduces no regressions in existing components.

#### 1.1 — Baseline Verification

Before running regression, confirm a visual baseline exists:

```bash
# Check if baseline exists for this component in Chromatic
npx chromatic --only-changed

# If no baseline: capture baseline first, then flag for manual design review
# A new component with no baseline requires apex-lead sign-off on first capture
```

#### 1.2 — Cross-Breakpoint Regression

Run visual snapshots at all 6 breakpoints:

```typescript
// playwright visual regression — all breakpoints
const breakpoints = [
  { name: 'mobile-s', width: 320, height: 812 },
  { name: 'mobile', width: 375, height: 812 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'desktop', width: 1024, height: 768 },
  { name: 'desktop-l', width: 1440, height: 900 },
  { name: '4k', width: 2560, height: 1440 },
];

for (const bp of breakpoints) {
  await page.setViewportSize({ width: bp.width, height: bp.height });
  await expect(page).toHaveScreenshot(`{ComponentName}-${bp.name}.png`, {
    maxDiffPixels: 0,  // Zero tolerance
  });
}
```

#### 1.3 — Cross-Theme Regression

Run snapshots in all three color modes:

```typescript
// Light mode (default)
await page.emulateMedia({ colorScheme: 'light' });
await expect(page).toHaveScreenshot('{ComponentName}-light.png', { maxDiffPixels: 0 });

// Dark mode
await page.emulateMedia({ colorScheme: 'dark' });
await expect(page).toHaveScreenshot('{ComponentName}-dark.png', { maxDiffPixels: 0 });

// High contrast (Windows forced-colors)
await page.emulateMedia({ forcedColors: 'active' });
await expect(page).toHaveScreenshot('{ComponentName}-high-contrast.png', { maxDiffPixels: 0 });
```

#### 1.4 — Interactive State Captures

Capture all interactive states:

```typescript
const states = [
  { name: 'default', action: null },
  { name: 'hover', action: async () => await component.hover() },
  { name: 'focus', action: async () => await component.focus() },
  { name: 'active', action: async () => /* simulate press */ },
  { name: 'loading', action: null },  // use loading story
  { name: 'disabled', action: null }, // use disabled story
  { name: 'error', action: null },    // use error story
  { name: 'empty', action: null },    // use empty story
];

for (const state of states) {
  if (state.action) await state.action();
  await expect(component).toHaveScreenshot(`{ComponentName}-${state.name}.png`, {
    maxDiffPixels: 0,
  });
}
```

#### 1.5 — Regression Tolerance Policy

```yaml
tolerance_policy:
  new_component: 0  # No tolerance — first capture requires apex-lead approval
  existing_component: 0  # Zero pixel difference from approved baseline
  exception_process: |
    If a pixel difference is intentional (design update):
    1. Flag the diff in the PR description
    2. Request apex-lead visual approval of the diff
    3. Update baseline after approval
    4. Document the intentional change
```

#### 1.6 — Quality Gate: QG-AX-008 (Visual Regression)

```yaml
QG-AX-008:
  name: "Visual Regression"
  checks:
    - id: "008-a"
      description: "Zero pixel regressions against approved baseline"
      measurement: "Chromatic / Playwright screenshot diff"
      tolerance: 0
    - id: "008-b"
      description: "All 6 breakpoints captured and verified"
      breakpoints: [320, 375, 768, 1024, 1440, 2560]
    - id: "008-c"
      description: "All three color modes tested (light, dark, high-contrast)"
    - id: "008-d"
      description: "All interactive states captured (hover, focus, active, loading, error, empty, disabled)"
    - id: "008-e"
      description: "New component baseline reviewed and approved by apex-lead"
      condition: "Only applies for first-time component capture"
  verdict: "PASS | FAIL"
  blocker: true
  on_fail: "List all failing snapshots with diff images. Block merge."
```

---

### Step 2 — Cross-Platform Device Tests (@qa-xplatform)

**Agent:** Michal (qa-xplatform)
**Input:** Implemented components across platforms
**Deliverable:** Cross-platform test report

Michal runs tests on real devices. Emulators are not acceptable for final QA.

#### 2.1 — Web Cross-Browser Tests

```typescript
// playwright.config.ts — cross-browser matrix
export default defineConfig({
  projects: [
    { name: 'Chrome', use: { ...devices['Desktop Chrome'] } },
    { name: 'Firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'Safari', use: { ...devices['Desktop Safari'] } },
    { name: 'Mobile Chrome', use: { ...devices['Pixel 5'] } },
    { name: 'Mobile Safari', use: { ...devices['iPhone 14'] } },
  ],
});
```

**Minimum browser support:**
- Chrome 120+
- Safari 17+
- Firefox 121+
- iOS Safari 16+
- Chrome for Android (latest)

#### 2.2 — Mobile Device Tests (Real Devices Required)

```
MANDATORY: Test on physical devices, not emulators.
Emulators miss: touch latency, GPU performance, gesture recognition nuances.

Required iOS devices:
- iPhone SE 3rd Gen (low-mid range, iOS 16)
- iPhone 15 (current flagship)

Required Android devices:
- Pixel 4a (low-mid range, Android 13)
- Pixel 8 (current flagship, Android 14)
```

**Detox E2E test matrix for mobile:**

```typescript
// {ComponentName}.e2e.ts — Detox tests
describe('{ComponentName}', () => {
  it('renders correctly on first load', async () => {
    await expect(element(by.id('{component-test-id}'))).toBeVisible();
  });

  it('responds to touch with haptic feedback', async () => {
    await element(by.id('{component-test-id}')).tap();
    // Verify action was triggered
  });

  it('respects minimum touch target size', async () => {
    const bounds = await element(by.id('{component-test-id}')).getAttributes();
    expect(bounds.frame.width).toBeGreaterThanOrEqual(44);
    expect(bounds.frame.height).toBeGreaterThanOrEqual(44);
  });

  it('handles gesture interactions correctly', async () => {
    // Test swipe, pinch, long-press as applicable
    await element(by.id('{component-test-id}')).swipe('left', 'fast');
  });

  it('works in offline mode', async () => {
    // Toggle network off, verify graceful degradation
    await device.setURLBlacklist(['.*']);
    await expect(element(by.id('{error-state-id}'))).toBeVisible();
  });

  it('maintains 60fps during animations', async () => {
    // Verify frame rate does not drop below 60fps
    // Measure with Flipper Performance Monitor
  });
});
```

#### 2.3 — Gesture Validation

For any component with gesture interactions:

```typescript
// Gesture test matrix
const gesturesToTest = [
  { gesture: 'tap', platforms: ['ios', 'android'] },
  { gesture: 'long-press', platforms: ['ios', 'android'] },
  { gesture: 'swipe-left', platforms: ['ios', 'android'] },
  { gesture: 'swipe-right', platforms: ['ios', 'android'] },
  { gesture: 'pinch-to-zoom', platforms: ['ios', 'android', 'spatial'] },
  { gesture: 'pull-to-refresh', platforms: ['ios', 'android'] },
];

// Each gesture must:
// 1. Trigger the correct action
// 2. Play the correct spring animation
// 3. Provide haptic feedback (where applicable)
// 4. Respect reduced-motion preference
```

#### 2.4 — Platform Parity Validation

```yaml
parity_checks:
  - check: "Component renders identically in both dark and light mode"
    platforms: [web, ios, android]
  - check: "Loading states appear before content on slow network"
    simulation: "Network throttling to Slow 3G"
  - check: "Empty states appear when no data is present"
    test: "Clear data, verify empty state renders"
  - check: "Error states appear and offer recovery action on failure"
    simulation: "API mock returning 500"
  - check: "Component is functional without network"
    test: "Airplane mode test"
```

#### 2.5 — VisionOS / Spatial Tests (if `spatial` in target_platforms)

```yaml
spatial_test_checklist:
  - test: "Component visible in visionOS simulator"
    tool: "Xcode + visionOS Simulator"
  - test: "Gaze interaction triggers correct action"
    tool: "visionOS Simulator (eye tracking simulation)"
  - test: "Pinch gesture works at 0.5m, 1m, and 2m virtual distances"
    tool: "visionOS Simulator"
  - test: "Component scales correctly with windowing"
    tool: "visionOS Simulator — resize window"
  - test: "Spatial depth/parallax effect feels natural"
    tool: "Manual review in simulator"
```

#### 2.6 — Quality Gate: QG-AX-009 (Cross-Platform Device Tests)

```yaml
QG-AX-009:
  name: "Cross-Platform Device Tests"
  checks:
    - id: "009-a"
      description: "iOS: tested on real iPhone SE 3rd Gen (iOS 16+)"
      evidence: "Screenshot or recording from real device"
    - id: "009-b"
      description: "Android: tested on real Pixel 4a (Android 13+)"
      evidence: "Screenshot or recording from real device"
    - id: "009-c"
      description: "Web: Playwright cross-browser matrix passes"
      browsers: [Chrome 120+, Firefox 121+, Safari 17+]
    - id: "009-d"
      description: "Gesture interactions validated on real devices"
    - id: "009-e"
      description: "Offline/error states tested"
    - id: "009-f"
      description: "60fps animations confirmed on low-mid range devices"
    - id: "009-g"
      description: "visionOS tested (if spatial is a target platform)"
      condition: "Only required when spatial in target_platforms"
  verdict: "PASS | FAIL"
  blocker: true
  on_fail: "List failing devices, failing scenarios, and steps to reproduce."
```

---

### Step 3 — Final Visual Review (@apex-lead)

**Agent:** Emil (apex-lead)
**Input:** Passing QG-AX-008 and QG-AX-009 reports
**Deliverable:** APPROVED or BLOCKED verdict

Emil performs the final visual review. This is the last gate before a feature is
approved for merge. Emil's authority is absolute — if it does not feel right, it
does not ship.

#### 3.1 — Visual Authority Checklist

```
Emil's review questions:

[ ] Does the interaction feel inevitable — like it could not have been designed any other way?
[ ] Does the spring motion energy match the interaction intent?
[ ] Does it look right on a 320px viewport? (not just "works", but looks right)
[ ] Does it feel native on mobile — not "adapted from web"?
[ ] Are the loading and empty states as considered as the primary state?
[ ] Is there anything that draws attention to itself as a design artifact?
    (good design should feel invisible)
[ ] Would the designer approve this pixel-for-pixel?
[ ] Does the reduced-motion version communicate the same intent without movement?
[ ] Is the focus state visually appropriate — not an afterthought?
[ ] Does anything feel "off" that the automated tests would not catch?
```

#### 3.2 — Cross-Platform Parity Check

Emil confirms the quality bar is equal across platforms:

```yaml
parity_review:
  question: "Does the web version feel like web-native?"
  question: "Does the mobile version feel like mobile-native?"
  question: "Are they recognizably the same product without feeling like ports?"
  standard: "Same quality bar, platform-appropriate expression"
```

#### 3.3 — Quality Gate: QG-AX-010 (Final Visual Review)

```yaml
QG-AX-010:
  name: "Final Visual Review"
  checks:
    - id: "010-a"
      description: "Interaction feels inevitable and intentional"
      assessment: "Subjective — apex-lead authority"
    - id: "010-b"
      description: "Motion matches the squad motion language"
    - id: "010-c"
      description: "Design fidelity confirmed pixel-for-pixel against spec"
    - id: "010-d"
      description: "Cross-platform parity at equal quality bar"
    - id: "010-e"
      description: "No detail overlooked (loading, empty, error, reduced-motion)"
    - id: "010-f"
      description: "Focus management and visible focus indicators approved"
  verdict: "APPROVED | BLOCKED"
  blocker: true
  authority: apex-lead
  on_approved: "Feature is approved for merge. Delegate push to @devops."
  on_blocked: "List specific issues. Route back to appropriate agent for fixes. Re-run ship flow after fixes."
```

---

## Ship Verdicts

### APPROVED

```yaml
verdict: APPROVED
message: >
  All 10 quality gates passed. Feature is approved for merge.

  Next step: Delegate to @devops for git push and PR creation.
  Command: @devops *push

gates_summary:
  - QG-AX-001: PASS
  - QG-AX-002: PASS
  - QG-AX-003: PASS
  - QG-AX-004: PASS
  - QG-AX-005: PASS
  - QG-AX-006: PASS
  - QG-AX-007: PASS
  - QG-AX-008: PASS
  - QG-AX-009: PASS
  - QG-AX-010: APPROVED
```

### BLOCKED

```yaml
verdict: BLOCKED
issues:
  - gate: "QG-AX-{number}"
    description: "{specific issue}"
    assigned_to: "@{agent-id}"
    action_required: "{what must be fixed}"

next_step: >
  Fix the issues listed above, then re-run apex-ship-flow.
  Do NOT attempt to merge until APPROVED verdict is received.
```

---

## Post-Approval: Delegate to @devops

Squad Apex agents do not push to remote or create PRs. After APPROVED verdict:

```
@devops *push

# @devops will:
# 1. Review the branch
# 2. Push to remote
# 3. Create PR with Apex Squad context
# 4. Request reviews as configured
```

---

## Quality Gate Summary

| Gate | ID | Owner | Blocker |
|------|----|-------|---------|
| Visual Regression | QG-AX-008 | @qa-visual | Yes |
| Cross-Platform Device Tests | QG-AX-009 | @qa-xplatform | Yes |
| Final Visual Review | QG-AX-010 | @apex-lead | Yes |

All three gates must pass. Ship verdict must be APPROVED before any merge.

---

*Apex Squad — Ship Flow Task v1.0.0*
