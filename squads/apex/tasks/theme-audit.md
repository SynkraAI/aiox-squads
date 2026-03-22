# Task: theme-audit

```yaml
id: theme-audit
version: "1.0.0"
title: "Theme Audit"
description: >
  Audit multi-mode theme support across the design system. Verifies each
  mode (light, dark, high-contrast, dark-high-contrast), checks that all
  colors use semantic tokens, validates contrast ratios against WCAG AA,
  tests mode switching behavior, and validates all component states in
  every mode.
elicit: false
owner: design-sys-eng
executor: design-sys-eng
outputs:
  - Theme audit report per mode
  - Contrast ratio validation results
  - Hardcoded color violation list
  - Mode switching test results
  - State-in-mode coverage matrix
```

---

## When This Task Runs

This task runs when:
- A new mode is being added (e.g., dark-high-contrast)
- New components are introduced that need mode validation
- Users report visual issues in specific modes
- A periodic theme health check is scheduled
- Token architecture changes affect mode values

This task does NOT run when:
- The issue is about component layout, not theming (route to `@interaction-dsgn`)
- The issue is about token naming, not mode values (use `naming-convention`)
- The issue is about Figma sync (use `figma-sync-setup`)

---

## Supported Modes

```yaml
modes:
  light:
    description: "Default mode. Light background, dark text."
    selector: '[data-theme="light"]'
    default: true

  dark:
    description: "Dark background, light text. Reduces eye strain."
    selector: '[data-theme="dark"]'

  high_contrast:
    description: "Enhanced contrast for low-vision users. Light background."
    selector: '[data-theme="high-contrast"]'
    wcag_target: "AAA (7:1)"

  dark_high_contrast:
    description: "Dark mode with enhanced contrast."
    selector: '[data-theme="dark-high-contrast"]'
    wcag_target: "AAA (7:1)"
```

---

## Execution Steps

### Step 1: Switch to Each Mode

Systematically test each mode:

1. Set the theme mode using the data attribute or theme switcher
2. Take a visual snapshot of key pages/screens in each mode:
   - Landing/home page
   - Form-heavy page
   - Data table / list page
   - Modal / dialog
   - Error / empty state page
3. Compare snapshots across modes to identify inconsistencies
4. Verify the mode class or attribute is correctly applied to the root element
5. Check that the mode persists across navigation and page reloads

### Step 2: Check All Colors Use Semantic Tokens

Scan the codebase for hardcoded color values:

1. Search for hardcoded hex colors: `#[0-9a-fA-F]{3,8}`
2. Search for hardcoded RGB/HSL: `rgb(`, `rgba(`, `hsl(`, `hsla(`
3. Search for named colors in CSS: `color: red`, `background: white`
4. For each hardcoded value found, determine:
   - Is it in a token definition file? (ALLOWED — primitives use raw values)
   - Is it in a component or page stylesheet? (VIOLATION — must use token)
   - Is it in a third-party override? (EXCEPTION — document reason)
5. Produce a violation report:

| File | Line | Value | Should Be |
|------|------|-------|-----------|
| card.css | 12 | #f3f4f6 | var(--color-bg-subtle) |
| header.css | 8 | white | var(--color-bg-default) |

### Step 3: Verify Contrast Ratios

Validate text and UI contrast against WCAG standards:

1. **Normal text (< 18px, or < 14px bold):**
   - AA minimum: 4.5:1
   - AAA target (high-contrast modes): 7:1
2. **Large text (>= 18px, or >= 14px bold):**
   - AA minimum: 3:1
   - AAA target: 4.5:1
3. **UI components and graphical objects:**
   - AA minimum: 3:1 against adjacent colors
4. Check contrast for all token pairs used as text-on-background:

| Token Pair | Light | Dark | HC | Dark HC |
|-----------|-------|------|-----|---------|
| text.default / bg.default | 15.2:1 | 13.4:1 | 18.3:1 | 17.1:1 |
| text.muted / bg.default | 4.8:1 | 5.1:1 | 8.2:1 | 7.5:1 |

5. Flag any pair below the AA threshold as a CRITICAL violation
6. Flag any pair below AAA in high-contrast modes as a WARNING

### Step 4: Test Mode Switching

Verify seamless transitions between modes:

1. **No flash on switch:**
   - Switching modes should not cause a flash of unstyled content (FOUC)
   - Verify CSS custom properties update instantly (no repaint delay)
   - Check for race conditions between JS mode toggle and CSS update
2. **No layout shift:**
   - Mode switching should not change element sizes or positions
   - Verify no CLS introduced by mode switching
3. **State preservation:**
   - Open modals, expanded accordions, form values should survive mode switch
   - Scroll position should be preserved
4. **Initial load:**
   - Check that the correct mode is applied before first paint
   - Verify no flash from default to user-preferred mode
   - Test with `prefers-color-scheme: dark` system preference
5. **Transition animation:**
   - If mode switch is animated, verify `prefers-reduced-motion` fallback
   - Transition should be short (< 200ms) and non-disruptive

### Step 5: Validate All States in All Modes

Test every component state in every mode:

1. Create a state-in-mode matrix:

| Component | State | Light | Dark | HC | Dark HC |
|-----------|-------|-------|------|-----|---------|
| Button | Default | OK | OK | OK | OK |
| Button | Hover | OK | FAIL | OK | OK |
| Button | Focus | OK | OK | OK | FAIL |
| Button | Disabled | OK | OK | OK | OK |
| Input | Error | OK | FAIL | OK | OK |

2. For each cell, verify:
   - The state is visually distinguishable from other states
   - Colors come from tokens (not hardcoded)
   - Contrast meets the mode's WCAG target
   - Focus indicators are visible
3. Flag FAIL cells with:
   - The specific issue (low contrast, invisible focus ring, wrong color)
   - The token that needs a mode value adjustment
   - Proposed fix value

---

## Output Format

```markdown
# Theme Audit Report

**Date:** {YYYY-MM-DD}
**Auditor:** @design-sys-eng
**Modes audited:** light, dark, high-contrast, dark-high-contrast

## Summary
- Hardcoded color violations: {N}
- Contrast failures: {N}
- Mode switching issues: {N}
- State-in-mode failures: {N}

## Hardcoded Color Violations
{Table from Step 2}

## Contrast Results
{Table from Step 3}

## Mode Switching
{Results from Step 4}

## State Coverage Matrix
{Matrix from Step 5}

## Verdict: {ALL MODES PASS | ISSUES FOUND | CRITICAL FAILURES}
```

---

*Apex Squad — Theme Audit Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-theme-audit
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (PASS/FAIL/NEEDS_WORK)"
    - "All four modes must be audited (light, dark, high-contrast, dark-high-contrast)"
    - "Every hardcoded color in component/page styles must be flagged as a violation"
    - "Contrast ratios must be validated against WCAG AA for all token pairs"
    - "State-in-mode matrix must cover all component states in all modes"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Theme audit report per mode, contrast ratio validation, hardcoded color violations, mode switching test results, and state-in-mode coverage matrix |
| Next action | Route contrast failures to `@css-eng` for fixes, token violations to `@design-sys-eng` for `token-architecture`, and mode switching issues to `@react-eng` |
