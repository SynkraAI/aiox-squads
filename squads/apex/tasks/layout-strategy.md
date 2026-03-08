# Task: layout-strategy

```yaml
id: layout-strategy
version: "1.0.0"
title: "Layout Strategy"
description: >
  Create or debug a CSS layout using the correct algorithm for the task.
  Determines whether the layout is 1D or 2D, selects Grid, Flexbox, or
  Flow accordingly, defines container query contexts, applies defensive
  CSS patterns, and tests at extreme viewport sizes.
elicit: false
owner: interaction-dsgn
executor: interaction-dsgn
outputs:
  - Layout strategy document with algorithm selection rationale
  - Container query context definitions
  - Defensive CSS patterns applied
  - Test results across extreme sizes (320px-2560px)
```

---

## When This Task Runs

This task runs when:
- A new page layout or section layout needs to be designed
- An existing layout has bugs (overflow, alignment, wrapping issues)
- A layout needs to be migrated from media queries to container queries
- A developer asks for guidance on Grid vs Flexbox for a specific case
- Layout breaks at certain viewport or container sizes

This task does NOT run when:
- The issue is about colors, typography, or spacing tokens (route to `@design-sys-eng`)
- The issue is about animation during layout transitions (route to `@motion-eng`)
- The issue is about component logic, not visual layout (route to `@react-eng`)

---

## Execution Steps

### Step 1: Identify Layout Type

Determine the dimensional nature of the layout:

1. **1D Layout (single axis):**
   - Items flow in one direction (row or column)
   - No relationship between rows is needed
   - Examples: navigation bars, button groups, card lists
   - → Use **Flexbox**

2. **2D Layout (both axes):**
   - Items need alignment across both rows and columns
   - Grid tracks define a clear structure
   - Examples: dashboards, image galleries, form grids
   - → Use **CSS Grid**

3. **Flow Layout:**
   - Content flows naturally with inline and block elements
   - No explicit alignment needed beyond normal flow
   - Examples: article text, comment threads
   - → Use **normal flow** with minimal overrides

4. Document the classification with rationale

### Step 2: Choose and Configure Algorithm

Implement the selected layout algorithm:

**For Flexbox (1D):**
1. Define `flex-direction` (row or column as primary axis)
2. Set `flex-wrap: wrap` for responsive behavior
3. Use `gap` instead of margins for consistent spacing
4. Set `flex` shorthand on children: `flex: 1 1 auto` or explicit basis
5. Handle alignment with `justify-content` and `align-items`
6. Apply `min-width: 0` on flex children to prevent overflow

**For Grid (2D):**
1. Define track templates: `grid-template-columns`, `grid-template-rows`
2. Use `minmax()` for fluid track sizing: `minmax(min-content, 1fr)`
3. Use `auto-fill` / `auto-fit` for dynamic column counts
4. Define named grid areas for complex layouts
5. Use `gap` for consistent gutter spacing
6. Set `min-width: 0` and `min-height: 0` on grid children

**For Flow Layout:**
1. Use semantic HTML elements for natural flow
2. Apply `max-width` for readable line lengths (45-75 characters)
3. Use `margin-block` for vertical rhythm
4. Let inline elements wrap naturally

### Step 3: Define Container Query Contexts

Set up container query containers for responsive components:

1. Identify which elements should be container query containers
2. Apply `container-type: inline-size` (most common) or `container-type: size`
3. Name containers with `container-name` for specificity
4. Define breakpoints based on container width, not viewport:
   - Compact: `@container (max-width: 300px)`
   - Default: `@container (min-width: 301px) and (max-width: 600px)`
   - Expanded: `@container (min-width: 601px)`
5. Document which layout changes happen at each container breakpoint
6. Verify container queries do not create layout cycles

### Step 4: Implement Defensive CSS

Apply defensive patterns to prevent layout breakage:

1. **Overflow protection:**
   - `overflow-wrap: break-word` on text containers
   - `overflow: hidden` or `overflow: auto` on bounded containers
   - `text-overflow: ellipsis` for single-line truncation
2. **Minimum size guards:**
   - `min-width: 0` on flex and grid children
   - `min-height: 0` to prevent grid blowout
3. **Image safety:**
   - `max-width: 100%` and `height: auto` on images
   - `aspect-ratio` with `object-fit: cover` for consistent sizing
4. **Content-aware sizing:**
   - `fit-content` for labels and badges
   - `clamp()` for fluid typography and spacing
5. **Scroll prevention:**
   - Check for unintended horizontal scroll at all sizes
   - Verify no element extends beyond its container bounds

### Step 5: Test at Extreme Sizes

Validate the layout across the full size spectrum:

1. **320px** — smallest supported mobile viewport
2. **375px** — common mobile (iPhone SE)
3. **768px** — tablet portrait
4. **1024px** — tablet landscape / small desktop
5. **1440px** — standard desktop
6. **1920px** — full HD
7. **2560px** — ultra-wide / 4K scaled
8. At each size, verify:
   - No horizontal overflow
   - Text is readable without horizontal scrolling
   - Interactive elements are at least 44x44px touch targets
   - Spacing feels proportional
   - Layout transitions happen at appropriate widths

### Step 6: Document Layout Decisions

Create a layout decision record:

1. Document the algorithm choice and why
2. Include the container query breakpoint definitions
3. List all defensive CSS patterns applied
4. Note any edge cases discovered and how they are handled
5. Add before/after screenshots if debugging an existing layout
6. Reference any related ADRs for the layout approach

---

## Common Layout Pitfalls

| Pitfall | Fix |
|---------|-----|
| Flex children overflowing | Add `min-width: 0` and `overflow: hidden` |
| Grid tracks not shrinking | Use `minmax(0, 1fr)` instead of `1fr` |
| Text pushing container wider | Add `overflow-wrap: break-word` |
| Images stretching layout | Use `max-width: 100%; height: auto` |
| Gap not working in older Safari | Use fallback margins with `@supports` |

---

*Apex Squad — Layout Strategy Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-layout-strategy
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Layout algorithm selection must include rationale (Grid vs Flexbox vs Flow)"
    - "Container query context definitions must specify breakpoints and layout changes"
    - "Defensive CSS patterns must be applied and documented"
    - "Layout must be tested at 320px and 2560px without horizontal overflow"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@css-eng` or `@react-eng` |
| Artifact | Layout strategy document with algorithm selection, container queries, defensive patterns, and test results |
| Next action | Implement the layout in production code following the specified algorithm and container query breakpoints |
