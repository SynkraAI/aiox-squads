# Task: theme-visual-testing

```yaml
id: theme-visual-testing
version: "1.0.0"
title: "Theme Visual Testing"
description: >
  Tests the visual appearance of the application across all
  supported themes (light, dark, high-contrast). Captures
  screenshots in each mode, compares against Figma design specs,
  verifies design token usage, and checks contrast ratios
  per mode. Ensures theme switching is visually correct.
elicit: false
owner: qa-visual
executor: qa-visual
outputs:
  - Light mode screenshots
  - Dark mode screenshots
  - High-contrast mode screenshots
  - Figma spec comparison results
  - Token usage verification
  - Contrast ratio checks per mode
```

---

## When This Task Runs

This task runs when:
- A new theme (dark mode, high contrast) has been implemented
- Design tokens have been updated and visual impact needs verification
- Theme-related bugs have been reported
- Before a release that includes theme changes
- `*theme-test` or `*test-themes` is invoked

This task does NOT run when:
- Only a single theme needs visual regression testing (use `visual-regression-audit`)
- Cross-browser testing is needed (use `cross-browser-validation`)
- Theme implementation needs design work (delegate to `@design-sys-eng`)

---

## Execution Steps

### Step 1: Capture Screenshots in Light Mode

Capture the complete visual state of the application in light/default mode.

**Capture configuration:**
```typescript
test.describe('Light Mode Visual Tests', () => {
  test.use({
    colorScheme: 'light',
  });

  const pages = [
    { name: 'homepage', url: '/' },
    { name: 'dashboard', url: '/dashboard' },
    { name: 'settings', url: '/settings' },
    { name: 'form', url: '/contact' },
    { name: 'components', url: '/storybook' },
  ];

  for (const page of pages) {
    test(`light: ${page.name}`, async ({ page: browserPage }) => {
      await browserPage.goto(page.url);
      await browserPage.waitForLoadState('networkidle');
      await expect(browserPage).toHaveScreenshot(
        `light-${page.name}.png`,
        { fullPage: true, animations: 'disabled' }
      );
    });
  }
});
```

**Component-level captures (recommended):**
- Buttons (all variants: primary, secondary, ghost, disabled)
- Form inputs (default, focused, error, filled)
- Cards and containers
- Navigation (active, inactive states)
- Alerts and notifications (info, success, warning, error)
- Tables and data displays
- Modals and overlays

**Output:** Complete light mode screenshot set.

### Step 2: Capture Screenshots in Dark Mode

Capture the same pages and components in dark mode.

**Dark mode activation:**
```typescript
test.describe('Dark Mode Visual Tests', () => {
  test.use({
    colorScheme: 'dark',
  });

  // Same pages as light mode...
});

// Alternative: toggle via application theme switcher
test('dark mode via toggle', async ({ page }) => {
  await page.goto('/');
  await page.click('[data-testid="theme-toggle"]');
  await page.waitForTimeout(300); // Wait for transition
  await expect(page).toHaveScreenshot('dark-homepage.png');
});
```

**Dark mode specific checks:**
- Background colors are truly dark (not just inverted)
- Text is readable on dark backgrounds
- Images and illustrations adapt (or have acceptable contrast)
- Shadows are adjusted for dark surfaces (lighter, more subtle)
- Borders and dividers are visible (not lost in dark backgrounds)
- Status colors (red, green, yellow) are adjusted for dark mode readability
- Code blocks and syntax highlighting adapt

**Common dark mode issues:**
- White flash during page transitions (background not set early enough)
- Images with white/transparent backgrounds looking wrong on dark
- Box shadows being invisible on dark backgrounds
- Hardcoded color values not using tokens (staying light in dark mode)

**Output:** Complete dark mode screenshot set.

### Step 3: Capture Screenshots in High-Contrast Mode

Capture the application in Windows High Contrast Mode / forced-colors mode.

**High contrast activation:**
```typescript
test.describe('High Contrast Mode', () => {
  test.use({
    // Playwright does not directly simulate forced-colors
    // Use media query emulation
  });

  test('high contrast', async ({ page }) => {
    await page.emulateMedia({ forcedColors: 'active' });
    await page.goto('/');
    await expect(page).toHaveScreenshot('hc-homepage.png');
  });
});
```

**High contrast checks:**
- All text is visible (system colors applied correctly)
- Focus indicators are visible (using `Highlight` system color)
- Borders are visible (using `ButtonText` or `CanvasText`)
- Custom icons and graphics are visible
- Form controls have visible boundaries
- Disabled states are distinguishable from enabled

**CSS for forced-colors support:**
```css
@media (forced-colors: active) {
  .button {
    border: 1px solid ButtonText; /* Ensure button has visible border */
  }

  .focus-ring:focus-visible {
    outline: 2px solid Highlight; /* System focus color */
  }

  .icon {
    forced-color-adjust: none; /* Preserve custom icon colors if needed */
  }
}
```

**Output:** High contrast mode screenshot set.

### Step 4: Compare Against Figma Specs

Compare captured screenshots against the design specifications in Figma.

**Comparison process:**
1. Export the corresponding Figma frames for each page/component
2. Place Figma export and screenshot side by side
3. Check each element against the spec

**What to compare:**

| Element | Check Against Figma |
|---------|-------------------|
| Colors | Do applied colors match the spec? (Extract hex from screenshot, compare) |
| Typography | Font family, weight, size, line-height match? |
| Spacing | Padding and margin match spec? |
| Border radius | Rounded corners match spec? |
| Shadows | Shadow color, offset, blur match spec? |
| Icons | Size, color, alignment match spec? |
| Layout | Grid/flex alignment match spec? |

**Tolerance guidelines:**
- Color: Must be within 1 shade (hex difference < #030303)
- Spacing: Must be within 2px
- Font size: Must match exactly
- Border radius: Must match exactly
- Layout: Must match at the same viewport width

**Document deviations:**
| Element | Figma Spec | Actual | Deviation | Acceptable? |
|---------|-----------|--------|-----------|-------------|
| Button padding | 12px 24px | 12px 24px | None | Yes |
| Card shadow | 0 4px 6px rgba(0,0,0,0.1) | 0 4px 8px rgba(0,0,0,0.12) | Slight | Review |

**Output:** Figma comparison report per theme.

### Step 5: Verify Token Usage

Confirm that all visual properties are using design tokens, not hardcoded values.

**Verification method:**
1. Inspect elements in DevTools
2. Check that CSS custom properties (tokens) are used, not literal values
3. When the theme changes, all properties should update via token changes

**What to check:**
```css
/* GOOD: Uses tokens — will adapt to theme changes */
.card {
  background-color: var(--color-surface);
  color: var(--color-on-surface);
  border: 1px solid var(--color-border);
  box-shadow: var(--shadow-md);
}

/* BAD: Hardcoded — will NOT adapt to theme changes */
.card {
  background-color: #ffffff;
  color: #333333;
  border: 1px solid #e0e0e0;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}
```

**Automated token check:**
```bash
# Search for hardcoded color values in CSS/JSX
# Flag any hex color, rgb(), or rgba() that is not inside a token definition
```

**Token audit results:**
| Component | Properties Using Tokens | Hardcoded Properties | Compliance |
|-----------|------------------------|---------------------|-----------|
| Button | 5/5 | 0 | 100% |
| Card | 4/5 | 1 (border-radius) | 80% |
| Input | 3/5 | 2 (focus color, placeholder) | 60% |

**Output:** Token usage audit per component.

### Step 6: Check Contrast Ratios Per Mode

Verify that all text and interactive elements meet WCAG contrast requirements in each theme mode.

**Test in each mode:**

| Mode | Background Context | Typical Issue |
|------|-------------------|---------------|
| Light | Light backgrounds, dark text | Secondary text too light |
| Dark | Dark backgrounds, light text | Muted colors too dim |
| High Contrast | System colors | Custom colors overridden |

**For each mode, check:**
- Body text contrast (must be >= 4.5:1)
- Heading contrast (must be >= 3:1 for large text)
- Button text on button background (per variant)
- Link text on surrounding background
- Placeholder text contrast (must be >= 4.5:1)
- Error/success/warning text on their backgrounds
- Icon contrast against background (>= 3:1)
- Focus indicator contrast (>= 3:1)

**Automated contrast check:**
```typescript
// axe-core in each color scheme
for (const scheme of ['light', 'dark']) {
  test(`contrast: ${scheme}`, async ({ page }) => {
    await page.emulateMedia({ colorScheme: scheme });
    await page.goto('/');
    const results = await new AxeBuilder({ page })
      .withTags(['wcag2aa'])
      .withRules(['color-contrast'])
      .analyze();
    expect(results.violations).toHaveLength(0);
  });
}
```

**Results format:**
| Element | Light Mode | Dark Mode | High Contrast |
|---------|-----------|-----------|---------------|
| Body text | 7.2:1 PASS | 6.8:1 PASS | System PASS |
| Secondary text | 4.1:1 FAIL | 3.8:1 FAIL | System PASS |
| Button (primary) | 5.5:1 PASS | 5.2:1 PASS | System PASS |

**Output:** Contrast ratio results per mode per element.

---

## Quality Criteria

- Screenshots must be captured in all supported themes
- Every page/component must be compared against Figma specs
- All visual properties must use design tokens (no hardcoded values in theme-aware components)
- Contrast ratios must pass WCAG AA in all theme modes
- Dark mode must not have any white flashes during navigation
- High contrast mode must maintain all interactive element boundaries

---

*Squad Apex — Theme Visual Testing Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-theme-visual-testing
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Screenshots must be captured in all supported themes (light, dark, high-contrast)"
    - "Every page/component must be compared against Figma specs"
    - "All visual properties must use design tokens (no hardcoded values in theme-aware components)"
    - "Contrast ratios must pass WCAG AA in all theme modes"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Light/dark/high-contrast mode screenshots, Figma spec comparison results, token usage verification, and contrast ratio checks per mode |
| Next action | Route Figma deviations to `@design-sys-eng`, contrast failures to `@css-eng`, and hardcoded values to `@design-sys-eng` for token migration |
