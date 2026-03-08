# Task: performance-budget-review

```yaml
id: performance-budget-review
version: "1.0.0"
title: "Performance Budget Review"
description: >
  Review and enforce the project's performance budgets. Runs Lighthouse
  and bundle analysis, compares results against defined thresholds, traces
  violations to specific code changes, and proposes fixes or requires an
  ADR exception for any budget exceeded.
elicit: false
owner: frontend-arch
executor: frontend-arch
outputs:
  - Performance budget report with pass/fail per metric
  - Violation trace to specific code changes
  - Fix proposals or ADR exception requirements
```

---

## When This Task Runs

This task runs when:
- A PR introduces new dependencies or significant code changes
- A story is reaching the QA gate and needs performance validation
- Core Web Vitals regression is detected in monitoring
- A periodic performance review is scheduled
- A Tier 3+ agent flags a potential performance concern

This task does NOT run when:
- Changes are documentation-only or configuration-only
- The change is within a test-only package with no production impact
- Performance profiling of a specific component is needed (route to `@perf-eng`)

---

## Performance Budgets

The following budgets are enforced for all production routes:

| Metric | Budget | Severity |
|--------|--------|----------|
| LCP (Largest Contentful Paint) | < 1.2s | CRITICAL |
| INP (Interaction to Next Paint) | < 200ms | CRITICAL |
| CLS (Cumulative Layout Shift) | < 0.1 | CRITICAL |
| First-load JS | < 80KB (gzipped) | CRITICAL |
| Total page weight | < 500KB | WARNING |
| Time to Interactive | < 2.0s | WARNING |
| First Contentful Paint | < 0.8s | WARNING |

---

## Execution Steps

### Step 1: Run Lighthouse and Bundle Analysis

Execute the performance measurement tools:

1. Run Lighthouse CI against the target route(s) in production mode
2. Execute the bundle analyzer to get per-route JS breakdown
3. Capture Core Web Vitals (LCP, INP, CLS) from Lighthouse report
4. Record first-load JS size per route (gzipped)
5. Generate the total page weight including all assets
6. Run measurements 3 times and take the median to reduce variance

### Step 2: Compare Against Budgets

Evaluate each metric against its budget:

1. For each metric, calculate: `actual value` vs `budget threshold`
2. Mark as PASS (within budget), WARNING (within 10% of budget), or FAIL (exceeds budget)
3. Calculate the delta for failed metrics (how much over budget)
4. Compare against the previous baseline (is this a regression or pre-existing?)
5. Produce a summary table:

```
| Metric | Budget | Actual | Status | Delta |
|--------|--------|--------|--------|-------|
| LCP    | 1.2s   | 1.4s   | FAIL   | +0.2s |
| INP    | 200ms  | 150ms  | PASS   | -50ms |
| ...    | ...    | ...    | ...    | ...   |
```

### Step 3: Identify Violations

For each FAIL or WARNING status:

1. Classify the violation type:
   - **Bundle regression** — new or larger dependencies
   - **Render regression** — layout thrashing, synchronous operations
   - **Asset regression** — unoptimized images, fonts, or media
   - **Architecture regression** — client-side code that should be server
2. Quantify the impact (how many milliseconds or KB over budget)
3. Determine if the violation is new (introduced by current changes) or pre-existing

### Step 4: Trace to Specific Code Changes

For new violations, trace to the responsible code:

1. Use `git diff` to identify changed files
2. Cross-reference changed files with the bundle analyzer output
3. Identify which specific imports or code paths caused the regression
4. For render regressions, use the Lighthouse treemap to find heavy modules
5. Document the trace: `{file}:{line} → {import/pattern} → +{KB or ms}`

### Step 5: Propose Fixes or Require ADR Exception

For each violation, provide a resolution path:

**If fixable:**
1. Propose specific code changes to bring the metric within budget
2. Suggest alternative approaches (lazy loading, code splitting, server component)
3. Estimate the expected improvement from each fix
4. Prioritize fixes by impact-to-effort ratio

**If not fixable without trade-offs:**
1. Require an ADR exception documenting why the budget is exceeded
2. The ADR must include:
   - Why the violation is necessary
   - What mitigation is in place
   - When the budget will be restored (with a timeline)
   - What the new temporary budget is
3. Route to `architecture-decision` task for ADR creation

---

## Budget Exception Process

```yaml
exception_rules:
  who_can_approve: "@frontend-arch"
  max_exception_duration: "2 sprints"
  requires_adr: true
  requires_mitigation_plan: true
  review_trigger: "exception expiry date"
```

Exceptions are tracked in `docs/architecture/performance-exceptions.md`.

---

## Report Format

```markdown
# Performance Budget Review

**Date:** {YYYY-MM-DD}
**Route(s):** {route paths analyzed}
**Reviewer:** @frontend-arch

## Summary
- Total metrics checked: {N}
- Passed: {N}
- Warnings: {N}
- Failed: {N}

## Results
{Table from Step 2}

## Violations
{Details from Steps 3-4}

## Recommended Actions
{Fixes from Step 5}

## Verdict: {ALL PASS | WARNINGS ONLY | BUDGET EXCEEDED}
```

---

*Apex Squad — Performance Budget Review Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-performance-budget-review
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (PASS/FAIL/NEEDS_WORK)"
    - "Every metric must be compared against its defined budget with pass/fail"
    - "Violations must be traced to specific code changes with file references"
    - "Fix proposals must include estimated improvement or ADR exception must be filed"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Performance budget report with pass/fail per metric, violation traces, and fix proposals |
| Next action | Route fixes to `@perf-eng` for `bundle-optimization` or `image-optimization`, or file ADR exception via `architecture-decision` |
