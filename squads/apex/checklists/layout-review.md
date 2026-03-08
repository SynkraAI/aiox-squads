# Layout Review Checklist — Apex Squad

> Reviewer: interaction-dsgn
> Purpose: Validate layout implementation correctness, responsiveness, and defensive CSS practices.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Layout Strategy

- [ ] Correct layout algorithm chosen for the context (Grid for 2D, Flexbox for 1D)
- [ ] Container query contexts defined on appropriate wrapper elements
- [ ] No nested flexbox deeper than 3 levels — refactored to Grid or named containers
- [ ] Layout properties match the algorithm context (no `justify-items` on flex containers)
- [ ] Grid template areas used for complex page layouts (readable and maintainable)
- [ ] Auto-placement leveraged where appropriate (no manual positioning of grid items)

---

## 2. Responsive

- [ ] Layout works at 320px minimum width without horizontal overflow
- [ ] Layout works at 2560px without excessive whitespace or stretching
- [ ] Content breathes at all intermediate sizes — no cramped or empty gaps
- [ ] Breakpoints use container queries for component-level responsiveness
- [ ] No fixed-width elements that break at narrow viewports
- [ ] Stack/row layout switches happen at natural content breakpoints

---

## 3. Defensive CSS

- [ ] `overflow-wrap: break-word` applied on text containers to prevent overflow
- [ ] `object-fit` set on all images to prevent distortion
- [ ] `min-width: 0` set on flex items to prevent content overflow
- [ ] `min-width: 0` set on grid items to prevent content overflow
- [ ] `aspect-ratio` defined on media elements for stable layout
- [ ] `max-width: 100%` on images and embedded content
- [ ] Scrollable containers have `overflow: auto` not `overflow: scroll` (no empty scrollbars)

---

## 4. RTL Support

- [ ] Logical properties used (`margin-inline-start` not `margin-left`)
- [ ] No physical `left`/`right` properties — replaced with `inline-start`/`inline-end`
- [ ] Layout tested in RTL mode (`dir="rtl"`) and renders correctly
- [ ] Icons that imply direction (arrows, chevrons) flip in RTL
- [ ] Text alignment uses `start`/`end` not `left`/`right`
- [ ] Flexbox `row` direction respects document direction automatically

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Result | APPROVED / BLOCKED |
| Notes | |
