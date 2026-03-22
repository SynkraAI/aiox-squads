# Task: css-architecture-audit

```yaml
id: css-architecture-audit
version: "1.0.0"
title: "CSS Architecture Audit"
description: >
  Performs a comprehensive audit of the CSS architecture to ensure
  mental model correctness. Examines layout algorithms, stacking contexts,
  cascade layers, custom property design, and fluid/fixed value strategy.
  Produces a detailed report with actionable recommendations for
  improving CSS maintainability and correctness.
elicit: false
owner: css-eng
executor: css-eng
outputs:
  - CSS architecture audit report
  - List of mental model violations
  - Prioritized recommendations for fixes
  - Stacking context hierarchy map
  - Custom properties API assessment
```

---

## When This Task Runs

This task runs when:
- A new codebase is being onboarded and CSS quality is unknown
- CSS bugs are recurring and suggest architectural issues (z-index wars, overflow clipping, unexpected layout shifts)
- Before a major UI redesign or design system migration
- The team suspects CSS complexity is increasing without structure
- `*audit-css` or `*css-architecture` is invoked

This task does NOT run when:
- A single CSS bug needs fixing (use `stacking-context-debug` instead)
- Only fluid typography is being set up (use `fluid-type-setup` instead)
- The project has no CSS (pure native app)

---

## Execution Steps

### Step 1: Identify Layout Algorithms in Use

Scan all stylesheets and component styles to identify which CSS layout algorithms are actively used across the project.

- Catalog usage of Flow, Flexbox, Grid, Positioned, Table, and Float layouts
- Identify cases where the wrong algorithm is chosen for the job (e.g., Flexbox used where Grid is more appropriate for 2D layouts)
- Flag any legacy layout patterns (float-based grids, clearfix hacks)
- Check that developers understand which algorithm controls each container — every element is governed by ONE layout algorithm at a time

**Output:** Layout algorithm inventory with misuse flags.

### Step 2: Audit Stacking Context Hierarchy

Map the complete stacking context tree of the application to identify unintentional or problematic context creation.

- Identify all elements that create new stacking contexts (position + z-index, opacity < 1, transform, filter, will-change, isolation, contain)
- Build a visual hierarchy tree of stacking contexts
- Flag z-index values that fight across different stacking contexts (z-index only works within the SAME context)
- Identify "z-index inflation" — values like 9999 that indicate broken mental models
- Check for `isolation: isolate` usage as an intentional context boundary

**Output:** Stacking context tree diagram with problem areas highlighted.

### Step 3: Check Cascade Layer Strategy

Evaluate whether the project uses CSS Cascade Layers (`@layer`) and if the cascade is managed intentionally.

- Check for `@layer` declarations and their ordering
- If no layers exist, assess whether the project would benefit from them (multi-source CSS, third-party styles, design system + app styles)
- Verify that specificity is managed through structure, not `!important` escalation
- Count `!important` usage and categorize: intentional (utility classes) vs. defensive (overriding other specificity)
- Check if CSS custom properties are used to avoid specificity wars

**Output:** Cascade management assessment with layer strategy recommendation.

### Step 4: Verify Custom Properties as API

Assess whether CSS custom properties (variables) are designed as a proper API layer or are used ad hoc.

- Check for a clear custom property naming convention (e.g., `--color-primary`, `--space-4`, `--font-size-lg`)
- Verify that custom properties provide meaningful semantic abstraction, not just value aliasing
- Check for proper fallback values in `var()` calls
- Assess whether custom properties are scoped appropriately (`:root` for global, component scope for local)
- Verify that custom properties serve as the theming API (light/dark mode, brand customization)

**Output:** Custom properties API quality assessment.

### Step 5: Check Fluid vs Fixed Values

Audit the use of fluid (responsive) vs fixed values throughout the codebase.

- Identify hardcoded pixel values that should be fluid (font sizes, spacing, container widths)
- Check for proper use of `clamp()`, `min()`, `max()` for fluid scaling
- Verify that `rem`/`em` are used appropriately (rem for global sizing, em for component-relative)
- Check viewport units usage (`vw`, `vh`, `dvh`) for correctness
- Identify breakpoint-heavy media queries that could be replaced with fluid values or container queries
- Assess container query usage where appropriate

**Output:** Fluid vs fixed value audit with conversion recommendations.

### Step 6: Generate Report with Recommendations

Compile all findings into a structured report with prioritized, actionable recommendations.

- **Critical:** Issues causing visual bugs or blocking scalability (stacking context wars, layout algorithm misuse)
- **High:** Issues that will cause problems at scale (no cascade strategy, no custom property API)
- **Medium:** Improvements for maintainability (fluid values, container queries)
- **Low:** Nice-to-have refinements (naming conventions, organization)

Include before/after code examples for the top 5 recommended changes.

**Output:** Final audit report saved to the story's documentation folder.

---

## Quality Criteria

- Every finding must reference a specific file and line
- Recommendations must include concrete code examples, not just descriptions
- The stacking context tree must be accurate and complete for the audited scope
- No recommendation should introduce a new mental model complexity without justification

---

*Squad Apex — CSS Architecture Audit Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-css-architecture-audit
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (PASS/FAIL/NEEDS_WORK)"
    - "Every finding must reference a specific file and line"
    - "Stacking context tree must be accurate and complete for the audited scope"
    - "Report must contain at least one actionable finding or explicit all-clear"
    - "Recommendations must include concrete before/after code examples"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` or `@frontend-arch` |
| Artifact | CSS architecture audit report with prioritized recommendations and stacking context map |
| Next action | Route critical/high findings to `@css-eng` for remediation or to `@frontend-arch` for architectural decisions |
