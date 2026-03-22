# Task: component-maturation

```yaml
id: component-maturation
version: "1.0.0"
title: "Component Maturation"
description: >
  Manage the lifecycle of a design system component through maturation
  levels. Assesses the current level, checks promotion criteria, verifies
  tests, Storybook documentation, mode support, and accessibility, then
  updates the maturation status accordingly.
elicit: false
owner: design-sys-eng
executor: design-sys-eng
outputs:
  - Maturation assessment report
  - Promotion checklist with pass/fail per criterion
  - Updated maturation status in component metadata
  - List of gaps to address before next promotion
```

---

## When This Task Runs

This task runs when:
- A new component is created and needs initial maturation classification
- A component is ready to be promoted to the next maturation level
- A periodic review of component maturation status is scheduled
- A component is being considered for use in a critical production feature
- A team member questions whether a component is stable enough for their use case

This task does NOT run when:
- The component needs design changes (route to `@interaction-dsgn`)
- The question is about component performance (route to `@perf-eng`)
- The component needs accessibility fixes (route to `@a11y-eng`)

---

## Maturation Levels

```yaml
levels:
  experimental:
    label: "Experimental"
    description: "Proof of concept. API will change. Not for production."
    usage: "Internal exploration and prototyping only"
    stability: "Breaking changes expected without notice"

  alpha:
    label: "Alpha"
    description: "Initial implementation. API stabilizing. Limited production use."
    usage: "Non-critical features with team awareness"
    stability: "Breaking changes with migration guide"

  beta:
    label: "Beta"
    description: "Feature-complete. API stable. Broad production use."
    usage: "Production features, including user-facing"
    stability: "Breaking changes only with deprecation cycle"

  stable:
    label: "Stable"
    description: "Battle-tested. API frozen. Universal use."
    usage: "All contexts, including critical paths"
    stability: "No breaking changes. New features via composition"
```

---

## Execution Steps

### Step 1: Assess Current Maturation Level

Determine where the component currently stands:

1. Check the component metadata for declared maturation level
2. Verify the component's actual state matches its declared level
3. Review the component's history:
   - When was it created?
   - How many breaking API changes in the last 3 months?
   - How many consumers (importers) does it have?
   - Are there open bugs or design issues?
4. If no maturation level is declared, classify based on the promotion criteria below

### Step 2: Check Promotion Criteria

Evaluate the component against the target level's requirements:

**Experimental → Alpha:**
- [ ] Component renders without errors
- [ ] Basic props API is defined with TypeScript types
- [ ] At least one Storybook story exists
- [ ] Component has a clear owner/maintainer
- [ ] README or JSDoc describes the intended purpose

**Alpha → Beta:**
- [ ] All props are documented with TypeScript and JSDoc
- [ ] Unit tests cover core functionality (>= 80% coverage)
- [ ] Storybook stories cover all variants (size, color, state)
- [ ] Light and dark mode supported and tested
- [ ] Keyboard navigation works for interactive elements
- [ ] No known critical bugs
- [ ] API has been stable for >= 2 weeks
- [ ] At least 2 consumers in the codebase

**Beta → Stable:**
- [ ] Full test suite (unit + integration, >= 90% coverage)
- [ ] Storybook stories for ALL modes (light, dark, high-contrast, dark-high-contrast)
- [ ] WCAG AA accessibility verified (contrast, keyboard, screen reader)
- [ ] Performance benchmarked (no render regressions)
- [ ] API has been stable for >= 4 weeks
- [ ] At least 5 consumers in the codebase
- [ ] Edge cases documented and handled (empty state, overflow, RTL)
- [ ] Migration guide exists from previous API versions (if applicable)
- [ ] CodeRabbit or peer review completed

### Step 3: Verify Tests, Storybook, Modes, and Accessibility

Run the verification checks:

1. **Tests:**
   - Run the component's test suite: `npm test -- --filter={component}`
   - Check coverage report against target threshold
   - Verify edge cases are tested (empty props, extreme values, error states)

2. **Storybook:**
   - Verify stories exist for: default, variants, sizes, states
   - Check that stories render without errors or warnings
   - Verify interactive controls (args) work correctly

3. **Mode support:**
   - Switch to each theme mode and verify visual correctness
   - Check that all colors use semantic tokens (no hardcoded values)
   - Verify mode switching does not cause layout shifts

4. **Accessibility:**
   - Run axe or similar automated accessibility check
   - Verify keyboard navigation order
   - Test with a screen reader (VoiceOver/NVDA)
   - Check focus indicator visibility in all modes

### Step 4: Document API Surface

Create or verify the component's API documentation:

1. List all props with types, defaults, and descriptions
2. Document slots/children API if applicable
3. List emitted events/callbacks
4. Document CSS custom properties for customization
5. Provide usage examples for common patterns
6. Note any props marked as deprecated with migration path

### Step 5: Update Maturation Status

Apply the promotion decision:

1. If all criteria PASS:
   - Update component metadata with new maturation level
   - Update Storybook badge/label
   - Announce the promotion in the changelog
   - Update the design system component inventory

2. If criteria have GAPS:
   - Document each gap with specific action items
   - Assign owners for each gap
   - Set a target date for re-evaluation
   - Keep the current maturation level

3. Update the component inventory:

| Component | Level | Last Review | Next Review | Gaps |
|-----------|-------|------------|-------------|------|
| Button | Stable | 2025-01-15 | 2025-04-15 | None |
| DataTable | Beta | 2025-01-20 | 2025-02-20 | HC mode |

---

## Deprecation Process

When a stable component needs to be replaced:

1. Mark the component as `deprecated` (not removed)
2. Create a migration guide from the old to the new component
3. Add console warnings in development: `console.warn('Component X is deprecated...')`
4. Set a deprecation timeline (minimum 2 releases)
5. Track migration progress across consumers

---

*Apex Squad — Component Maturation Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-component-maturation
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Maturation assessment must reference the defined promotion criteria checklist"
    - "Each promotion criterion must have an explicit pass/fail status"
    - "Gaps list must include specific action items with assigned owners"
    - "Updated maturation status must be reflected in component metadata"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Maturation assessment report with promotion checklist results and gap list |
| Next action | Route gap items to appropriate agents (`@a11y-eng`, `@qa-visual`, `@react-eng`) or confirm promotion |
