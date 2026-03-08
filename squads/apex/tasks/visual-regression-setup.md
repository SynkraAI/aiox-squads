# Task: visual-regression-setup

```yaml
id: visual-regression-setup
version: "1.0.0"
title: "Visual Regression Testing Setup"
description: >
  Sets up visual regression testing infrastructure to detect
  unintended visual changes. Chooses the tooling approach,
  configures baseline screenshot capture, defines viewports
  for comparison, integrates with CI, configures pixel-diff
  thresholds, and documents the workflow.
elicit: false
owner: qa-visual
executor: qa-visual
outputs:
  - Tool selection with rationale
  - Baseline capture configuration
  - Viewport definition for comparisons
  - CI integration setup
  - Pixel-diff threshold configuration
  - Workflow documentation
```

---

## When This Task Runs

This task runs when:
- The project has no visual regression testing and needs it
- A design system is being established and visual consistency matters
- Visual regressions keep reaching production undetected
- The team is migrating CSS/styling approaches and needs safety nets
- `*visual-regression-setup` or `*setup-visual-testing` is invoked

This task does NOT run when:
- Visual regression tests exist and only need to be run (use `visual-regression-audit`)
- The task is about cross-browser testing (use `cross-browser-validation`)
- The task is about theme testing (use `theme-visual-testing`)

---

## Execution Steps

### Step 1: Choose Tool

Select the visual regression testing tool based on project requirements.

**Options:**

| Tool | Type | Hosting | Best For |
|------|------|---------|----------|
| **Playwright Screenshots** | Open source, self-hosted | Local/CI | Budget-conscious, full control |
| **Chromatic** | Managed service | Cloud | Storybook-based projects, team review |
| **Percy** | Managed service | Cloud | Cross-browser visual testing |
| **BackstopJS** | Open source | Local/CI | Simple setup, URL-based testing |
| **Argos** | Managed service | Cloud | GitHub integration, simple review |

**Decision criteria:**

| Factor | Playwright | Chromatic | Percy |
|--------|-----------|-----------|-------|
| Cost | Free | Free tier (5K snapshots/mo) | Paid |
| Setup effort | Medium | Low (Storybook addon) | Medium |
| Browser coverage | Chromium, Firefox, WebKit | Chromium | Multiple browsers |
| Component isolation | Manual | Storybook integration | Manual |
| Review UI | Manual diff | Built-in UI | Built-in UI |
| CI integration | Native | GitHub, GitLab | GitHub, GitLab |

**Recommended:**
- If using Storybook → Chromatic (best integration)
- If budget-constrained → Playwright screenshots (free, flexible)
- If cross-browser is critical → Percy (multi-browser rendering)

**Output:** Tool selection with rationale.

### Step 2: Configure Baseline Capture

Set up the initial baseline screenshots that all future comparisons will be made against.

**Playwright approach:**
```typescript
// visual-regression.spec.ts
import { test, expect } from '@playwright/test';

const pages = [
  { name: 'homepage', url: '/' },
  { name: 'dashboard', url: '/dashboard' },
  { name: 'settings', url: '/settings' },
  { name: 'login', url: '/login' },
];

for (const page of pages) {
  test(`visual: ${page.name}`, async ({ page: browserPage }) => {
    await browserPage.goto(page.url);
    await browserPage.waitForLoadState('networkidle');

    // Wait for fonts and images to load
    await browserPage.waitForTimeout(500);

    await expect(browserPage).toHaveScreenshot(`${page.name}.png`, {
      fullPage: true,
      animations: 'disabled', // Prevent animation flakiness
    });
  });
}
```

**Component-level baselines (Storybook + Chromatic):**
```typescript
// Button.stories.tsx
export const Primary: Story = {
  args: { variant: 'primary', children: 'Click me' },
};

export const AllVariants: Story = {
  render: () => (
    <div style={{ display: 'flex', gap: 16 }}>
      <Button variant="primary">Primary</Button>
      <Button variant="secondary">Secondary</Button>
      <Button variant="ghost">Ghost</Button>
      <Button disabled>Disabled</Button>
    </div>
  ),
};
```

**Baseline capture considerations:**
- Disable animations during capture (prevents flaky diffs)
- Wait for all images and fonts to load
- Use consistent viewport sizes
- Mask dynamic content (timestamps, avatars, ads)
- Set a fixed system date for date-dependent content

**Output:** Baseline capture configuration with initial baselines generated.

### Step 3: Define Viewports for Comparison

Establish the viewport sizes that screenshots will be captured at.

**Standard viewport set:**

| Name | Width | Height | Represents |
|------|-------|--------|------------|
| mobile-portrait | 375px | 812px | iPhone 13/14 |
| mobile-landscape | 812px | 375px | iPhone landscape |
| tablet-portrait | 768px | 1024px | iPad |
| tablet-landscape | 1024px | 768px | iPad landscape |
| desktop-hd | 1280px | 800px | Standard laptop |
| desktop-fhd | 1920px | 1080px | Full HD monitor |
| desktop-wide | 2560px | 1440px | Wide/4K monitor |

**Minimum viewport set (for faster CI):**

| Name | Width | Height | Why |
|------|-------|--------|-----|
| mobile | 375px | 812px | Most common mobile |
| tablet | 768px | 1024px | Breakpoint boundary |
| desktop | 1440px | 900px | Common desktop |

**Playwright configuration:**
```typescript
// playwright.config.ts
export default defineConfig({
  projects: [
    {
      name: 'mobile',
      use: { viewport: { width: 375, height: 812 } },
    },
    {
      name: 'tablet',
      use: { viewport: { width: 768, height: 1024 } },
    },
    {
      name: 'desktop',
      use: { viewport: { width: 1440, height: 900 } },
    },
  ],
});
```

**Output:** Viewport configuration for all visual regression tests.

### Step 4: Set Up CI Integration

Configure visual regression tests to run automatically on pull requests.

**GitHub Actions integration:**
```yaml
name: Visual Regression
on: [pull_request]

jobs:
  visual-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install dependencies
        run: npm ci

      - name: Install Playwright browsers
        run: npx playwright install --with-deps chromium

      - name: Build application
        run: npm run build

      - name: Start server
        run: npm run start &
        env:
          PORT: 3000

      - name: Wait for server
        run: npx wait-on http://localhost:3000

      - name: Run visual regression tests
        run: npx playwright test --project=visual

      - name: Upload diff artifacts
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: visual-diffs
          path: test-results/
          retention-days: 7
```

**Baseline management strategy:**
- Baselines are committed to the repository (`__screenshots__/` directory)
- When a visual change is intentional, update baselines with `npx playwright test --update-snapshots`
- PR review must verify baseline updates are intentional
- Do NOT auto-update baselines — require human review

**Output:** CI configuration with baseline management strategy.

### Step 5: Configure Pixel-Diff Threshold

Set the acceptable pixel difference threshold for visual comparisons.

**Playwright threshold options:**
```typescript
await expect(page).toHaveScreenshot('page.png', {
  maxDiffPixels: 0,           // Strict: no pixel differences allowed
  maxDiffPixelRatio: 0.001,   // Allow 0.1% of pixels to differ
  threshold: 0.2,              // Per-pixel color difference tolerance (0-1)
  animations: 'disabled',
});
```

**Recommended settings:**

| Strictness | maxDiffPixelRatio | threshold | Use For |
|-----------|-------------------|-----------|---------|
| Strict | 0 | 0.1 | Design system components |
| Standard | 0.001 (0.1%) | 0.2 | Full pages |
| Relaxed | 0.01 (1%) | 0.3 | Pages with dynamic content |

**Masking dynamic content:**
```typescript
await expect(page).toHaveScreenshot('page.png', {
  mask: [
    page.locator('.timestamp'),
    page.locator('.avatar'),
    page.locator('.ad-banner'),
  ],
});
```

**Anti-aliasing handling:**
Different rendering engines produce slightly different anti-aliasing. Use `threshold: 0.2` to account for sub-pixel rendering differences across environments.

**Output:** Threshold configuration per test category.

### Step 6: Document Workflow

Create documentation for the visual regression testing workflow.

**Developer workflow:**
```
1. Make changes to code
2. Run visual tests locally: `npx playwright test --project=visual`
3. If tests fail:
   a. Review the diff (test-results/ directory)
   b. If change is intentional: update baseline
      `npx playwright test --update-snapshots --project=visual`
   c. If change is unintentional: fix the regression
4. Commit code + updated baselines (if any)
5. CI runs visual tests on PR
6. Reviewer verifies baseline changes in the PR diff
```

**Reviewing visual changes:**
- Baseline updates show as image diffs in the PR
- Reviewer must confirm each change is intentional
- Unexpected changes should be flagged as regressions

**Maintaining baselines:**
- Update baselines when design changes are approved
- Never update baselines to "make tests pass" without understanding the change
- If baselines become stale (too many accumulated changes), schedule a baseline refresh

**Output:** Visual regression workflow documentation.

---

## Quality Criteria

- Baselines must be captured at a minimum of 3 viewport sizes
- Animations must be disabled during capture to prevent flakiness
- CI must run visual tests on every pull request
- Pixel-diff threshold must be strict enough to catch regressions but not cause false positives
- Baseline updates must be reviewed by a human before merging
- Dynamic content must be masked to prevent false failures

---

*Squad Apex — Visual Regression Testing Setup Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-visual-regression-setup
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Baselines must be captured at a minimum of 3 viewport sizes"
    - "Animations must be disabled during capture to prevent flakiness"
    - "CI must run visual tests on every pull request"
    - "Baseline updates must require human review before merging"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Tool selection with rationale, baseline capture configuration, viewport definitions, CI integration, pixel-diff threshold configuration, and workflow documentation |
| Next action | Coordinate CI integration with `@devops` and run initial `visual-regression-audit` to validate setup |
