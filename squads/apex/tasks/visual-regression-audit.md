# Task: visual-regression-audit

```yaml
id: visual-regression-audit
version: "1.0.0"
title: "Visual Regression Audit"
description: >
  Runs a visual regression audit by capturing current screenshots
  across all defined viewports, comparing against baselines,
  reviewing diffs to classify changes as intentional or regressions,
  updating baselines for intentional changes, and filing issues
  for genuine regressions.
elicit: false
owner: qa-visual
executor: qa-visual
outputs:
  - Current screenshots across all viewports
  - Comparison results against baselines
  - Diff review and classification
  - Updated baselines (for intentional changes)
  - Filed issues for regressions
  - Audit summary report
```

---

## When This Task Runs

This task runs when:
- A sprint is complete and visual consistency needs verification
- Before a release to production
- After a CSS refactoring, design token update, or theme change
- A dependency upgrade may have affected visual rendering
- `*visual-audit` or `*run-visual-regression` is invoked

This task does NOT run when:
- Visual regression infrastructure needs to be set up first (use `visual-regression-setup`)
- The task is cross-browser specific (use `cross-browser-validation`)
- The task is theme-specific (use `theme-visual-testing`)

---

## Execution Steps

### Step 1: Capture Current Screenshots

Run the visual regression test suite to capture fresh screenshots of the current state.

**Execution:**
```bash
# Run all visual tests, capturing new screenshots
npx playwright test --project=visual

# Or for Chromatic
npx chromatic --project-token=$TOKEN
```

**Pre-capture checklist:**
- [ ] Application is built with production configuration
- [ ] All test data/fixtures are seeded consistently
- [ ] Animations are disabled (via test configuration)
- [ ] Fonts are loaded (wait for `document.fonts.ready`)
- [ ] No pending API calls (wait for `networkidle`)
- [ ] Dynamic content is masked or fixed (timestamps, counters)

**Capture scope:**
- All defined pages (homepage, dashboard, settings, etc.)
- All defined viewports (mobile, tablet, desktop)
- Key component states (default, hover, active, disabled, error, loading)
- All theme variants if applicable (light mode, dark mode)

**Output:** Complete screenshot set for current state.

### Step 2: Compare Against Baselines

Execute pixel-level comparison between current screenshots and stored baselines.

**Comparison process:**
```bash
# Playwright automatically compares when baselines exist
npx playwright test --project=visual
# Failed tests indicate visual differences

# Generate diff report
# Playwright creates diff images in test-results/ directory
```

**Comparison outputs per screenshot:**
- **Match:** Current matches baseline within threshold → PASS
- **Diff detected:** Pixels differ beyond threshold → FAIL (needs review)
- **New baseline:** No existing baseline → NEW (needs initial approval)
- **Missing:** Baseline exists but page/component was removed → ORPHANED

**Diff summary:**
| Page | Viewport | Status | Diff Pixels | Diff % |
|------|----------|--------|-------------|--------|
| Homepage | mobile | PASS | 0 | 0% |
| Homepage | desktop | DIFF | 1,247 | 0.3% |
| Dashboard | mobile | DIFF | 8,543 | 2.1% |
| Dashboard | desktop | PASS | 12 | 0.001% |
| Settings | all | PASS | 0 | 0% |

**Output:** Comparison results table with diff percentages.

### Step 3: Review Diffs

Examine each visual difference and classify it.

**Classification categories:**

| Category | Description | Action |
|----------|-------------|--------|
| **Intentional** | Expected change from a design update or feature | Update baseline |
| **Regression** | Unexpected visual change, likely a bug | File issue |
| **Flaky** | Diff caused by timing, font rendering, or anti-aliasing | Improve test stability |
| **Cosmetic** | Minor sub-pixel difference, not visible to users | Adjust threshold or ignore |

**Diff review process:**
For each diff:
1. Open the diff image (shows baseline, current, and highlighted differences)
2. Determine if the change relates to a recent code change
3. Check if any PR in the current branch modified related CSS/components
4. If the change is unexpected, investigate the source

**Review questions:**
- Does this diff correspond to a known design change?
- Could this diff be caused by a dependency update?
- Is the diff isolated to one viewport or across all viewports?
- Is the diff in a component used by multiple pages?

**Output:** Classification of each diff with rationale.

### Step 4: Update Baselines for Intentional Changes

For diffs classified as intentional, update the baseline screenshots.

**Update process:**
```bash
# Update specific test baselines
npx playwright test --update-snapshots --grep "homepage"

# Update all baselines (use with caution)
npx playwright test --update-snapshots
```

**Before updating, verify:**
- [ ] The design change has been approved by the design team
- [ ] The change looks correct across all viewports
- [ ] The change does not negatively affect adjacent elements
- [ ] The change is consistent with the design system tokens

**Commit baseline updates:**
- Commit updated baselines with a descriptive message: `chore: update visual baselines for [feature/change]`
- Reference the PR or story that caused the visual change
- Include a summary of what changed in the commit message

**Output:** Updated baseline files committed with documentation.

### Step 5: File Issues for Regressions

For diffs classified as regressions, create actionable issues.

**Issue template:**
```markdown
## Visual Regression: [Component/Page] at [Viewport]

### What Changed
[Description of the visual difference]

### Screenshots
| Baseline | Current | Diff |
|----------|---------|------|
| ![baseline](link) | ![current](link) | ![diff](link) |

### Affected Scope
- Page: [page name]
- Viewport: [viewport name]
- Component: [component if identifiable]

### Likely Cause
- [Recent CSS change in PR #X]
- [Dependency update]
- [Unknown — needs investigation]

### Severity
- [ ] Critical: User-facing visual break
- [ ] Major: Noticeable inconsistency
- [ ] Minor: Subtle difference, low visibility

### Steps to Reproduce
1. Navigate to [page]
2. Resize to [viewport]
3. Observe [element]
```

**Issue creation:**
```bash
gh issue create --title "Visual regression: [description]" \
  --body "$(cat regression-report.md)" \
  --label "bug,visual-regression"
```

**Output:** Filed issues for all confirmed regressions.

### Step 6: Generate Audit Summary

Compile the full audit into a summary report.

```markdown
## Visual Regression Audit Summary

### Date: [date]
### Scope: [pages/components audited]

### Results
| Category | Count |
|----------|-------|
| Screenshots captured | {N} |
| Passing (no diff) | {N} |
| Intentional changes | {N} (baselines updated) |
| Regressions found | {N} (issues filed) |
| Flaky tests | {N} (stability improvements needed) |

### Intentional Changes
1. [Page/component] — [what changed and why]
2. ...

### Regressions Filed
1. #{issue-number} — [brief description]
2. ...

### Stability Issues
1. [Test name] — [flakiness cause and recommended fix]

### Recommendations
- [Any systemic issues observed]
- [Improvements to the testing setup]
```

**Output:** Audit summary report.

---

## Quality Criteria

- Every diff must be reviewed and classified (no unreviewed diffs)
- Baseline updates must reference the design change that caused them
- Regression issues must include before/after screenshots
- Flaky tests must be documented with root cause and fix plan
- The audit must cover all defined viewports

---

*Squad Apex — Visual Regression Audit Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-visual-regression-audit
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (PASS/FAIL/NEEDS_WORK)"
    - "Every diff must be reviewed and classified (no unreviewed diffs)"
    - "Baseline updates must reference the design change that caused them"
    - "Regression issues must include before/after screenshots with severity rating"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Current screenshots, comparison results, diff classification, updated baselines, filed regression issues, and audit summary report |
| Next action | Route regression issues to responsible agents (`@css-eng`, `@react-eng`, `@design-sys-eng`) for fixes |
