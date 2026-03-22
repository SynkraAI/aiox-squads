# Task: responsive-audit

```yaml
id: responsive-audit
version: "1.0.0"
title: "Responsive Audit"
description: >
  Audit responsive behavior across the codebase and migrate from viewport
  media queries to container queries where appropriate. Inventories existing
  breakpoints, classifies them as component-level or page-level, converts
  component breakpoints to container queries, and tests in multiple contexts.
elicit: false
owner: interaction-dsgn
executor: interaction-dsgn
outputs:
  - Media query inventory with classification
  - Migration plan from media queries to container queries
  - Updated component styles with container queries
  - Documentation of new responsive patterns
```

---

## When This Task Runs

This task runs when:
- A component behaves differently when placed in different layout contexts
- Media queries are used for component-level styling (should be container queries)
- A responsive audit is scheduled as part of a design system review
- A new layout context is introduced and existing components need validation
- Components designed for one context need to work in another (sidebar, modal, main)

This task does NOT run when:
- The issue is about a single component's internal layout (use `layout-strategy`)
- The responsive issue is caused by incorrect content (route to `@design-sys-eng`)
- The issue is about mobile-native responsive behavior (route to `@mobile-eng`)

---

## Execution Steps

### Step 1: Inventory Current Media Queries

Scan the codebase for all responsive breakpoints:

1. Search for all `@media` rules across stylesheets and CSS-in-JS
2. Catalog each breakpoint value used (e.g., 768px, 1024px, 1280px)
3. Record the file, selector, and what changes at each breakpoint
4. Identify duplicate or near-duplicate breakpoints (e.g., 767px vs 768px)
5. Count total media queries and group by breakpoint value
6. Flag inconsistent breakpoint values that should be unified

### Step 2: Classify Component vs Page-Level

Determine which breakpoints belong to components vs page layout:

**Component-level breakpoints** (candidates for container queries):
- Style changes that depend on the component's available space
- Breakpoints that respond to the component's context, not the viewport
- Examples: card layout changes, sidebar content reflow, form field stacking
- Classification: MIGRATE to container queries

**Page-level breakpoints** (keep as media queries):
- Global layout shifts (sidebar visibility, navigation mode)
- Typography scale changes that affect the entire page
- Breakpoints that genuinely respond to the viewport size
- Classification: KEEP as media queries

Document the classification for each media query:

| Selector | Breakpoint | Classification | Rationale |
|----------|-----------|---------------|-----------|
| `.card` | 768px | MIGRATE | Card layout depends on container |
| `.nav` | 1024px | KEEP | Navigation is viewport-dependent |

### Step 3: Convert to Container Queries

For each MIGRATE-classified breakpoint:

1. Identify the container element (the parent that defines available space)
2. Add `container-type: inline-size` to the container
3. Optionally add `container-name` for specificity
4. Replace `@media (min-width: Xpx)` with `@container (min-width: Xpx)`
5. Adjust breakpoint values based on container width (not viewport width):
   - A card at `@media (min-width: 768px)` may need `@container (min-width: 400px)`
   - The container is narrower than the viewport
6. Verify the conversion does not change visual behavior in the current layout

### Step 4: Test in Multiple Container Contexts

Validate that migrated components work everywhere:

1. Place the component in different layout contexts:
   - Full-width main content area
   - Sidebar (narrow container, ~300px)
   - Modal dialog (medium container, ~500px)
   - Grid cell (variable width)
   - Dashboard widget (small container, ~200px)
2. At each context, verify:
   - The component adapts correctly to the container width
   - Container query breakpoints fire at the right widths
   - No layout overflow or visual breakage
   - Text remains readable and interactive elements remain usable
3. Test with nested containers to verify no query conflicts

### Step 5: Document New Patterns

Create documentation for the responsive strategy:

1. List all container query containers and their names
2. Document the breakpoint values used for container queries
3. Provide before/after examples for migrated components
4. Create a guide for developers on when to use media vs container queries:

```
Use @media when:
  - The layout change is about the VIEWPORT (navigation, global sidebar)
  - The style is truly page-level

Use @container when:
  - The layout change is about the COMPONENT'S AVAILABLE SPACE
  - The component might be placed in different contexts
  - The breakpoint would need to change if the page layout changes
```

5. Document any edge cases or browser compatibility considerations

---

## Mandatory Breakpoint Checklist

Every responsive audit MUST validate against these breakpoints:

| Breakpoint | Width | Device Category | Priority |
|------------|-------|-----------------|----------|
| **Mobile S** | 320px | iPhone SE, Galaxy Fold | CRITICAL |
| **Mobile M** | 375px | iPhone 12/13/14 | CRITICAL |
| **Tablet** | 768px | iPad, tablets | HIGH |
| **Desktop** | 1024px | Laptops, small desktops | HIGH |
| **Desktop L** | 1440px | Full HD monitors | MEDIUM |

### Per-Breakpoint Validation

At EACH breakpoint, verify:

1. **Layout:** No horizontal overflow, no content cut-off
2. **Typography:** Text readable, no truncation without ellipsis
3. **Touch targets:** Minimum 44x44px on mobile breakpoints (320, 375)
4. **Navigation:** Menu accessible and usable
5. **Forms:** Inputs usable, keyboards don't obscure fields
6. **Images:** Properly sized, no distortion
7. **Spacing:** Appropriate for screen size (tighter on mobile, looser on desktop)

### Result Format

```
| Breakpoint | Status | Issues |
|------------|--------|--------|
| 320px      | PASS/FAIL | {issue list} |
| 375px      | PASS/FAIL | {issue list} |
| 768px      | PASS/FAIL | {issue list} |
| 1024px     | PASS/FAIL | {issue list} |
| 1440px     | PASS/FAIL | {issue list} |
```

---

## Migration Checklist

Before completing the audit, verify:

- [ ] All media queries are inventoried and classified
- [ ] Component-level breakpoints are migrated to container queries
- [ ] Page-level breakpoints remain as media queries
- [ ] Components tested in at least 3 different container contexts
- [ ] Mandatory breakpoints (320, 375, 768, 1024, 1440) validated
- [ ] No visual regressions introduced by migration
- [ ] Documentation updated with new responsive patterns
- [ ] Browser support verified (container queries: Chrome 105+, Firefox 110+, Safari 16+)

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-RA-001
    condition: "Responsive audit delivered without testing 320px breakpoint"
    action: "VETO — Mobile S (320px) is mandatory. Test on smallest viewport."
    available_check: "manual"
    on_unavailable: MANUAL_CHECK

  - id: VC-RA-002
    condition: "Component has horizontal overflow at any mandatory breakpoint"
    action: "VETO — Fix overflow before proceeding. No horizontal scroll on mobile."
    available_check: "manual"
    on_unavailable: MANUAL_CHECK

  - id: VC-RA-003
    condition: "Touch target smaller than 44x44px at mobile breakpoints"
    action: "WARN — WCAG 2.5.8 Target Size. Enlarge interactive elements."
    available_check: "manual"
    on_unavailable: MANUAL_CHECK
```

---

*Apex Squad — Responsive Audit Task v1.1.0*

---

## Quality Gate

```yaml
gate:
  id: QG-responsive-audit
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (PASS/FAIL/NEEDS_WORK)"
    - "Every media query must be inventoried and classified as MIGRATE or KEEP"
    - "Components migrated to container queries must be tested in at least 3 different container contexts"
    - "Documentation must include when to use media queries vs container queries"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@css-eng` or `@apex-lead` |
| Artifact | Media query inventory with classification, migration plan, updated container query styles, and responsive pattern documentation |
| Next action | Implement remaining migrations via `@css-eng` or validate visual regressions via `@qa-visual` |
