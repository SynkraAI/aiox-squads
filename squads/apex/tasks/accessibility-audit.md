# Task: accessibility-audit

```yaml
id: accessibility-audit
version: "1.0.0"
title: "Accessibility Audit"
description: >
  Performs a comprehensive accessibility audit of a component or page
  covering automated scanning (axe-core), keyboard navigation,
  screen reader testing, color contrast, focus management, and
  ARIA pattern validation. Generates a detailed audit report with
  severity-ranked findings and remediation guidance.
elicit: false
owner: a11y-eng
executor: a11y-eng
outputs:
  - Axe-core automated scan results
  - Keyboard navigation test results
  - Screen reader test results
  - Color contrast analysis
  - Focus management assessment
  - ARIA pattern validation
  - Comprehensive audit report
```

---

## When This Task Runs

This task runs when:
- A new component or page is ready for accessibility review
- Before a release, to verify WCAG compliance
- A user reports an accessibility issue
- The team wants to establish an accessibility baseline
- `*a11y-audit` or `*accessibility-audit` is invoked

This task does NOT run when:
- A specific focus management issue needs design (use `focus-management-design`)
- A specific ARIA pattern needs implementation (use `aria-pattern-implementation`)
- Only screen reader testing is needed (use `screen-reader-testing`)

---

## Execution Steps

### Step 1: Run axe-core Automated Scan

Execute automated accessibility scanning to identify programmatically detectable issues.

**Tools:**
- axe-core via browser extension (axe DevTools)
- axe-core via Playwright/Cypress for CI
- Lighthouse accessibility audit

**Running the scan:**
```typescript
// Playwright integration
import AxeBuilder from '@axe-core/playwright';

test('page should not have accessibility violations', async ({ page }) => {
  await page.goto('/target-page');
  const results = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
    .analyze();

  // Categorize results
  const critical = results.violations.filter(v => v.impact === 'critical');
  const serious = results.violations.filter(v => v.impact === 'serious');
  const moderate = results.violations.filter(v => v.impact === 'moderate');
  const minor = results.violations.filter(v => v.impact === 'minor');
});
```

**What axe-core catches:**
- Missing alt text on images
- Missing form labels
- Insufficient color contrast
- Invalid ARIA attributes
- Missing document language
- Empty buttons/links
- Duplicate IDs

**What axe-core CANNOT catch (requires manual testing):**
- Logical tab order
- Meaningful alt text (it checks existence, not quality)
- Screen reader announcement quality
- Focus management correctness
- Cognitive accessibility
- Interaction pattern correctness

**Output:** axe-core results categorized by severity.

### Step 2: Test Keyboard Navigation

Navigate the entire audited scope using ONLY the keyboard.

**Keyboard testing protocol:**
1. Place focus at the top of the page (Tab from address bar)
2. Tab through every interactive element
3. Verify EVERY interactive element is reachable via Tab
4. Verify focus order matches visual order (left-to-right, top-to-bottom)
5. Test Escape to close modals/dropdowns
6. Test Enter/Space to activate buttons and links
7. Test Arrow keys for navigation within composite widgets (tabs, menus, radio groups)

**What to check:**
| Check | Pass Criteria |
|-------|--------------|
| Tab order | Follows visual layout, logical sequence |
| Focus visible | Every focused element has a visible focus indicator |
| No focus traps | User can always Tab out (except modals, which should trap intentionally) |
| Skip links | Skip-to-content link is present and works |
| Interactive elements | All clickable elements are keyboard-accessible |
| Custom widgets | Follow ARIA authoring practices keyboard patterns |
| No focus loss | Focus is never lost to `<body>` after an interaction |

**Common keyboard failures:**
- `<div onClick>` without `tabIndex`, `role`, or `onKeyDown` — not keyboard accessible
- Custom dropdown that only responds to mouse click
- Focus disappears after modal close (should return to trigger)
- Tab order jumps unexpectedly due to CSS positioning vs DOM order mismatch

**Output:** Keyboard navigation test results with failures documented.

### Step 3: Test with Screen Reader

Navigate the audited scope with a screen reader to verify announcements are correct and complete.

**Primary screen reader testing:**
- **VoiceOver (macOS):** Cmd+F5 to enable, VO+Right Arrow to navigate
- **NVDA (Windows):** Free screen reader, most used on Windows
- **VoiceOver (iOS):** Triple-click home/side button

**What to verify with screen reader:**
| Element | Expected Announcement |
|---------|----------------------|
| Button | "Submit, button" (role + name) |
| Link | "Read more about pricing, link" (purpose + role) |
| Image | "Chart showing revenue growth, image" (meaningful alt) |
| Heading | "Main navigation, heading level 2" (text + level) |
| Form input | "Email address, edit text, required" (label + role + state) |
| Error message | "Email is invalid, alert" (announced when it appears) |
| Loading | "Loading content, progress" (communicated dynamically) |

**Screen reader navigation modes:**
- Browse mode: Arrow keys read through content
- Forms mode: Tab between form elements
- Headings: H key to jump between headings
- Landmarks: D key (NVDA) to jump between regions

**Common screen reader failures:**
- Decorative images announced (should have `alt=""`)
- Dynamic content not announced (missing `aria-live`)
- Custom components with no role announced as "group" or nothing
- Error messages not announced when they appear
- Loading state not communicated

**Output:** Screen reader test results with announcement quality assessment.

### Step 4: Check Color Contrast Ratios

Verify all text and interactive elements meet WCAG color contrast requirements.

**WCAG 2.1 contrast requirements:**

| Element | AA Minimum | AAA Target |
|---------|-----------|------------|
| Normal text (< 18pt / < 14pt bold) | 4.5:1 | 7:1 |
| Large text (>= 18pt / >= 14pt bold) | 3:1 | 4.5:1 |
| UI components (borders, icons, focus) | 3:1 | 3:1 |
| Non-text contrast (charts, graphs) | 3:1 | 3:1 |

**Testing tools:**
- Chrome DevTools: Inspect element → color picker shows contrast ratio
- Colour Contrast Analyser (standalone app)
- axe-core (catches most contrast issues in Step 1)

**Check across all states:**
- Default state text contrast
- Hover state text contrast
- Focus state indicator contrast
- Disabled state (not required to meet contrast, but should be distinguishable)
- Selected/active state contrast
- Error state text and border contrast
- Dark mode contrast (if applicable)
- Placeholder text contrast (must meet 4.5:1)

**Common contrast failures:**
- Light gray placeholder text on white background
- Subtle focus indicators (thin light borders)
- Text on gradient or image backgrounds (check at darkest AND lightest point)
- Disabled state that is indistinguishable from enabled

**Output:** Contrast audit results per component state.

### Step 5: Verify Focus Management

Assess how focus is managed during dynamic interactions.

**Focus management scenarios:**

| Scenario | Expected Focus Behavior |
|----------|------------------------|
| Modal opens | Focus moves to first focusable element in modal |
| Modal closes | Focus returns to the element that triggered the modal |
| Item deleted from list | Focus moves to next item (or previous if last) |
| Tab panel changes | Focus moves to the tab panel content |
| Dropdown opens | Focus moves to first option |
| Error on submit | Focus moves to first invalid field |
| Route change (SPA) | Focus moves to new page heading or main content |
| Toast/notification | Announced via aria-live, focus NOT moved (non-modal) |

**Focus trap verification (modals/dialogs):**
1. Open the modal
2. Tab through all focusable elements
3. At the last element, Tab should cycle back to the first (not escape the modal)
4. Shift+Tab from the first element should cycle to the last
5. Escape should close the modal AND return focus

**Focus visible verification:**
- Every focusable element must show a visible focus indicator
- Focus indicator must have at least 3:1 contrast against adjacent colors
- Focus indicator must not be obscured by other elements (z-index issues)

**Output:** Focus management assessment per interaction.

### Step 6: Check ARIA Patterns

Validate that custom interactive widgets follow WAI-ARIA Authoring Practices.

**Reference:** [WAI-ARIA Authoring Practices 1.2](https://www.w3.org/WAI/ARIA/apg/)

For each custom widget, verify:
- Correct `role` is set
- Required ARIA states are present (`aria-expanded`, `aria-selected`, `aria-checked`)
- ARIA states update when interaction occurs
- Keyboard pattern matches the ARIA pattern specification
- `aria-labelledby` or `aria-label` provides accessible name

**Common ARIA violations:**
- `role="button"` without `tabIndex="0"` and keyboard handlers
- `aria-expanded` not toggling on open/close
- Tab list without `role="tablist"`, `role="tab"`, `role="tabpanel"`
- Combobox missing `aria-activedescendant` for virtual focus
- Menu items missing `role="menuitem"`
- Live regions (`aria-live`) that are too verbose or not verbose enough

**Output:** ARIA pattern compliance per widget.

### Step 7: Generate Audit Report

Compile all findings into a comprehensive audit report.

```markdown
## Accessibility Audit Report — [Scope]

### Summary
- WCAG Level: AA / AAA
- Total issues found: {N}
- Critical: {N} | Serious: {N} | Moderate: {N} | Minor: {N}

### Automated Scan (axe-core)
[Results from Step 1]

### Keyboard Navigation
[Results from Step 2]

### Screen Reader
[Results from Step 3]

### Color Contrast
[Results from Step 4]

### Focus Management
[Results from Step 5]

### ARIA Patterns
[Results from Step 6]

### Prioritized Remediation
1. [Critical] Fix: ...
2. [Serious] Fix: ...
```

**Output:** Complete audit report with prioritized remediation plan.

---

## Quality Criteria

- Automated scanning must use axe-core with WCAG 2.1 AA ruleset
- Keyboard testing must cover every interactive element in scope
- Screen reader testing must use at least one screen reader
- All text must meet WCAG AA contrast minimums (4.5:1 / 3:1)
- Every custom widget must be validated against WAI-ARIA Authoring Practices
- The report must include specific file locations and remediation steps

---

*Squad Apex — Accessibility Audit Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-accessibility-audit
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (PASS/FAIL/NEEDS_WORK)"
    - "Axe-core automated scan must be executed with zero critical/serious violations or documented exceptions"
    - "Keyboard navigation must be tested for all interactive elements"
    - "Screen reader testing must cover at least one screen reader (VoiceOver, NVDA, or TalkBack)"
    - "Report must contain at least one actionable finding or explicit all-clear"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Comprehensive accessibility audit report with severity-ranked findings |
| Next action | Route remediation items to `@a11y-eng` for `aria-pattern-implementation` or `focus-management-design` tasks |
