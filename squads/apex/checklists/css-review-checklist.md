# CSS Code Review Checklist — Apex Squad

> Reviewer: css-eng
> Purpose: Review CSS for correctness, performance, and maintainability best practices.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Layout Algorithm

- [ ] Correct layout algorithm identified for the use case (Grid, Flexbox, Flow)
- [ ] Properties match the algorithm context (no `align-items` on block elements)
- [ ] No algorithm confusion (e.g., `justify-content` on a non-flex/grid container)
- [ ] Grid used for 2D layouts, Flexbox for 1D distribution
- [ ] `display: contents` used intentionally and with a11y awareness
- [ ] Subgrid used where children need to align to parent grid tracks

---

## 2. Stacking Contexts

- [ ] No accidental stacking context creation from `transform`, `opacity < 1`, or `filter`
- [ ] `z-index` values are reasonable and within defined scale (no `z-index: 9999`)
- [ ] `isolation: isolate` used intentionally to create scoped stacking contexts
- [ ] Modal/overlay z-index follows the established layer system
- [ ] Stacking context documented when intentionally created
- [ ] No z-index wars between components

---

## 3. Fluid Design

- [ ] `clamp()` used for fluid typography (min, preferred, max)
- [ ] Relative units used for spacing (`rem`, `em`, viewport units with clamp)
- [ ] No fixed `px` breakpoints — fluid transitions preferred
- [ ] Viewport units used carefully (avoid `100vh` on mobile — use `100dvh`)
- [ ] `calc()` expressions are readable and documented if complex
- [ ] Fluid spacing scales proportionally with viewport

---

## 4. Custom Properties

- [ ] CSS custom properties used as component API surface
- [ ] Fallback values defined for all custom properties (`var(--color, #000)`)
- [ ] Custom properties scoped to component (not polluting global scope)
- [ ] Naming convention follows project standard (`--component-property`)
- [ ] Custom properties are not just CSS variables — they serve as theming/config API
- [ ] No circular references in custom property definitions

---

## 5. Cascade

- [ ] CSS Layer strategy consistent (`@layer base, components, utilities`)
- [ ] No `!important` declarations — refactored to use proper specificity
- [ ] Specificity is manageable — no deeply nested selectors
- [ ] No ID selectors in stylesheets (class-based approach)
- [ ] Utility classes have appropriate layer assignment
- [ ] Third-party CSS properly layered to allow overrides

---

## 6. Selectors and Performance

- [ ] No universal selectors (`*`) in performance-critical paths
- [ ] Selectors are efficient — no deeply nested descendant selectors
- [ ] `:has()` and `:is()` used appropriately with browser support awareness
- [ ] No layout-triggering properties in animations (prefer `transform`, `opacity`)
- [ ] `contain` property used where appropriate for rendering optimization
- [ ] `content-visibility: auto` considered for off-screen content

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Result | APPROVED / BLOCKED |
| Notes | |
