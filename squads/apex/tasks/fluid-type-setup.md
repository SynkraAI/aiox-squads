# Task: fluid-type-setup

```yaml
id: fluid-type-setup
version: "1.0.0"
title: "Fluid Typography Setup"
description: >
  Sets up a complete fluid typography system using CSS clamp() that
  scales smoothly between a minimum viewport (320px) and a maximum
  viewport (2560px). Defines a type scale with readable minimums,
  comfortable maximums, and calculated preferred values. The result
  is a set of custom properties that eliminate the need for
  font-size media queries.
elicit: false
owner: css-eng
executor: css-eng
outputs:
  - Fluid type scale CSS custom properties
  - Type scale documentation with visual preview
  - Tested at 320px and 2560px viewports
  - Integration guide for existing components
```

---

## When This Task Runs

This task runs when:
- A new project needs a typography system from scratch
- The existing typography relies on breakpoint-based media queries for font sizing
- A design system migration requires fluid typography
- `*fluid-type` or `*setup-typography` is invoked

This task does NOT run when:
- Typography is already fluid and working correctly
- The project uses a third-party type scale that cannot be customized
- Only a single font size needs adjustment (that is a bug fix, not a system setup)

---

## Execution Steps

### Step 1: Define Minimum Readable Sizes

Establish the minimum font size for each step in the type scale. These are the sizes at the smallest supported viewport (320px).

- **Body text (base):** 16px minimum — never smaller for readability
- **Small text:** 14px minimum — captions, labels, metadata
- **H6:** 16px — same as body at minimum
- **H5:** 18px
- **H4:** 20px
- **H3:** 24px
- **H2:** 28px
- **H1:** 32px
- **Display:** 36px

Validate that all minimum sizes meet WCAG readability guidelines. Body text must be at least 16px on mobile. No text in the scale should go below 12px under any circumstance.

**Output:** Minimum size table for each type scale step.

### Step 2: Define Maximum Comfortable Sizes

Establish the maximum font size for each step at the largest supported viewport (2560px).

- **Body text (base):** 20px maximum — larger feels uncomfortable for long-form reading
- **Small text:** 16px
- **H6:** 20px
- **H5:** 24px
- **H4:** 30px
- **H3:** 38px
- **H2:** 48px
- **H1:** 64px
- **Display:** 80px

Verify that maximum sizes maintain visual hierarchy — each step must be clearly distinguishable from adjacent steps. Check that line-height scales appropriately (tighter for larger headings, looser for body).

**Output:** Maximum size table for each type scale step.

### Step 3: Calculate Preferred Values

Calculate the preferred (fluid) value for each step using the viewport-relative formula.

The formula for `clamp()` preferred value:
```
preferred = min-size + (max-size - min-size) * ((100vw - min-viewport) / (max-viewport - min-viewport))
```

Simplified for CSS:
```css
/* For min: 16px, max: 20px, viewport range 320px-2560px */
--font-size-base: clamp(1rem, 0.929rem + 0.357vw, 1.25rem);
```

Calculate each step:
- Convert px values to rem (base 16px)
- Calculate the slope: `(max - min) / (max-viewport - min-viewport)`
- Calculate the intercept: `min - slope * min-viewport`
- Express as `clamp(min-rem, intercept-rem + slope-vw, max-rem)`

Round slope to 3 decimal places for readability.

**Output:** Calculated clamp() values for each type scale step.

### Step 4: Create Type Scale with clamp()

Implement the complete type scale as CSS custom properties.

```css
:root {
  /* Fluid Type Scale — 320px to 2560px */
  --font-size-sm:      clamp(0.875rem, /* calculated */, /* max */);
  --font-size-base:    clamp(1rem, /* calculated */, 1.25rem);
  --font-size-h6:      clamp(1rem, /* calculated */, 1.25rem);
  --font-size-h5:      clamp(1.125rem, /* calculated */, 1.5rem);
  --font-size-h4:      clamp(1.25rem, /* calculated */, 1.875rem);
  --font-size-h3:      clamp(1.5rem, /* calculated */, 2.375rem);
  --font-size-h2:      clamp(1.75rem, /* calculated */, 3rem);
  --font-size-h1:      clamp(2rem, /* calculated */, 4rem);
  --font-size-display: clamp(2.25rem, /* calculated */, 5rem);

  /* Corresponding line heights */
  --line-height-tight:   1.1;
  --line-height-snug:    1.25;
  --line-height-normal:  1.5;
  --line-height-relaxed: 1.625;
}
```

Also define letter-spacing adjustments for headings (tighter tracking at larger sizes) and font-weight mappings if the typeface supports variable weights.

**Output:** Complete CSS custom property declarations.

### Step 5: Test at 320px and 2560px

Verify the type scale at both extremes and several intermediate viewpoints.

- **320px:** All text is readable, nothing is too small, hierarchy is clear
- **768px:** Intermediate check — fluid scaling should be smooth
- **1440px:** Desktop check — sizes should feel comfortable
- **2560px:** Maximum viewport — nothing is oversized, hierarchy still works
- **4K (3840px):** Verify clamp() caps at maximum — no runaway growth

Test with actual content paragraphs, not just Lorem Ipsum. Verify that:
- Body text is comfortable to read in 60-75 character line widths
- Headings create clear visual hierarchy at every viewport
- No text overlaps or breaks layout at any viewport size

**Output:** Screenshots or confirmation at each viewport breakpoint.

### Step 6: Document Scale

Create documentation for the type scale that other developers can reference.

- Visual preview showing each step at minimum, preferred, and maximum sizes
- Usage guide: which custom property to use for each context
- Integration instructions for existing components
- Note on how to extend the scale if new steps are needed
- Explanation of the clamp() formula for future maintenance

**Output:** Type scale documentation file.

---

## Quality Criteria

- All clamp() values must be mathematically correct
- No font size in the system should ever render below 12px
- Body text must be at least 16px at 320px viewport
- The scale must be usable with a single custom property per element — no media queries needed
- Line heights must be appropriate for each scale step

---

*Squad Apex — Fluid Typography Setup Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-fluid-type-setup
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "All clamp() values must be mathematically correct"
    - "No font size in the system renders below 12px at any viewport"
    - "Body text must be at least 16px at 320px viewport"
    - "Type scale must be tested and verified at 320px and 2560px viewports"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@design-sys-eng` or `@apex-lead` |
| Artifact | Fluid type scale CSS custom properties with documentation and viewport test results |
| Next action | Integrate type scale tokens into the design system and update component typography references |
