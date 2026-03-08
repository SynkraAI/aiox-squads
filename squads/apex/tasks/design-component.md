# Task: design-component

```yaml
id: design-component
version: "1.0.0"
title: "Design Component"
description: >
  Design a UI component using visual-first methodology. Starts with a
  content audit, defines layout strategy, container query breakpoints,
  edge cases, motion specification, and accessibility annotations. Produces
  a complete design specification ready for implementation.
elicit: false
owner: interaction-dsgn
executor: interaction-dsgn
outputs:
  - Component design specification
  - Layout strategy document
  - Edge case matrix
  - Motion specification with reduced-motion fallback
  - Accessibility annotation layer
```

---

## When This Task Runs

This task runs when:
- A new component needs to be designed before implementation
- An existing component needs a design refresh or redesign
- The `*design` flow routes a component design request to `@interaction-dsgn`
- A story requires interaction design before coding begins

This task does NOT run when:
- The component already has a complete design spec and no changes are needed
- The task is purely about token mapping (route to `@design-sys-eng`)
- The task is about animation tuning only (route to `@motion-eng`)

---

## Execution Steps

### Step 1: Content Audit

Understand every piece of content the component must handle:

1. Identify all text content and their expected lengths:
   - Minimum length (single word, abbreviation)
   - Typical length (average use case)
   - Maximum length (worst case, localized text)
2. Identify image/media content:
   - Expected aspect ratios
   - Fallback when image is missing or fails to load
3. Identify optional fields:
   - What does the component look like when optional data is absent?
   - What combination of optional fields creates the worst layout?
4. Identify dynamic content:
   - Content that changes after initial render (live data, counters)
   - Content that varies by user role or permissions
5. Document all content variants in a content matrix

### Step 2: Layout Strategy

Choose and define the layout algorithm:

1. Determine layout type:
   - **1D layout** (single axis) → Flexbox
   - **2D layout** (rows and columns) → CSS Grid
   - **Hybrid** → Grid for page, Flexbox for components
2. Define the layout structure:
   - Grid template areas and track definitions
   - Flex direction, wrapping, and alignment
   - Minimum and maximum content sizes
3. Set intrinsic sizing where possible (`min-content`, `max-content`, `fit-content`)
4. Define spacing using design tokens (not hardcoded values)
5. Document the layout decision with rationale

### Step 3: Container Query Breakpoints

Define responsive behavior using container queries:

1. Identify the container context (what parent controls the size?)
2. Define container query breakpoints based on component needs (not viewport):
   - **Compact** — minimum viable layout
   - **Default** — standard comfortable layout
   - **Expanded** — uses available space fully
3. Specify what changes at each breakpoint:
   - Layout shifts (stack to row, grid reflow)
   - Content visibility (show/hide secondary content)
   - Typography scale changes
4. Test breakpoints at container widths: 200px, 320px, 480px, 768px, 1024px

### Step 4: Edge Cases

Design for every edge case:

1. **Long text** — what happens with text 3x longer than expected?
2. **Missing data** — what does the component show with null/undefined fields?
3. **RTL** — does the layout mirror correctly for right-to-left languages?
4. **Zoom** — does the component work at 200% and 400% browser zoom?
5. **Narrow container** — what happens at 200px width?
6. **Ultra-wide container** — what happens at 2560px width?
7. **Multiple items** — what happens with 0, 1, 3, 100+ items?
8. **Loading state** — skeleton, spinner, or progressive loading?
9. **Error state** — how does the component display error conditions?
10. Document each edge case with expected visual behavior

### Step 5: Motion Specification

Define animations and transitions:

1. Identify all state transitions that need motion:
   - Entry/exit animations
   - State changes (hover, focus, active, disabled)
   - Content transitions (loading → loaded, collapsed → expanded)
2. Specify motion parameters:
   - Duration range (100ms-300ms for micro-interactions)
   - Easing curve (prefer spring-based for natural feel)
   - Delay (stagger for sequential items)
3. Define `prefers-reduced-motion` fallback:
   - Replace animations with instant transitions or opacity-only fades
   - Never remove functional motion cues entirely
4. Document the motion specification for handoff to `@motion-eng`

### Step 6: Accessibility Annotation Layer

Create the accessibility specification:

1. Define semantic HTML structure (heading levels, landmarks, lists)
2. Specify ARIA attributes needed:
   - `role`, `aria-label`, `aria-describedby`, `aria-expanded`, etc.
3. Define keyboard interaction model:
   - Tab order through interactive elements
   - Arrow key navigation within composite widgets
   - Escape to dismiss, Enter/Space to activate
4. Specify focus management:
   - Focus trap for modals/dialogs
   - Focus restoration on close
   - Visible focus indicator styling
5. Define screen reader announcements:
   - Live regions for dynamic content
   - Status messages for async operations
6. Verify contrast ratios against WCAG AA (4.5:1 text, 3:1 UI)

---

## Output Format

```markdown
# Component Design: {Component Name}

**Designer:** @interaction-dsgn
**Date:** {YYYY-MM-DD}
**Status:** Draft | Ready for Implementation

## Content Matrix
{From Step 1}

## Layout Strategy
{From Step 2}

## Container Query Breakpoints
{From Step 3}

## Edge Cases
{From Step 4}

## Motion Specification
{From Step 5}

## Accessibility
{From Step 6}
```

---

*Apex Squad — Design Component Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-design-component
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Layout strategy must specify the chosen CSS layout algorithm with rationale"
    - "Edge case matrix must cover at least long text, missing data, RTL, and zoom scenarios"
    - "Motion specification must include reduced-motion fallback"
    - "Accessibility annotation layer must define semantic HTML, ARIA attributes, and keyboard model"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@react-eng` or `@css-eng` |
| Artifact | Complete component design specification with layout strategy, edge cases, motion spec, and accessibility annotations |
| Next action | Implement the component following the design spec, starting with `component-design` for architecture then `@css-eng` for styling |
