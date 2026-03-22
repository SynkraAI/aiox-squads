# Responsive Design Completeness Checklist — Apex Squad

> Reviewer: interaction-dsgn
> Purpose: Ensure components and layouts adapt fluidly across all viewport sizes.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Container Queries

- [ ] Component-level breakpoints use `@container` instead of `@media` where appropriate
- [ ] `container-type` set on parent contexts (`inline-size` or `size`)
- [ ] Named containers used for clarity (`container-name` assigned)
- [ ] No `@media` queries inside reusable components — prefer container queries
- [ ] Container query fallback provided for unsupported browsers if needed
- [ ] Nesting of container queries tested and working correctly

---

## 2. Fluid Values

- [ ] Typography uses `clamp()` for fluid scaling (e.g., `clamp(1rem, 2.5vw, 2rem)`)
- [ ] Spacing scales smoothly between breakpoints — no jarring jumps
- [ ] No hardcoded `px` breakpoint jumps for font sizes or spacing
- [ ] Fluid values tested at extreme viewport sizes (320px and 2560px)
- [ ] `clamp()` min values ensure readability on smallest screens
- [ ] `clamp()` max values prevent oversized elements on large screens

---

## 3. Extreme Sizes

- [ ] 320px (mobile-s) tested — content readable, no horizontal overflow
- [ ] 2560px (4K) tested — layout does not stretch excessively, content centered
- [ ] Portrait orientation tested on mobile and tablet sizes
- [ ] Landscape orientation tested on mobile and tablet sizes
- [ ] Ultra-wide aspect ratios (21:9) tested — content remains usable
- [ ] Pinch-to-zoom works without breaking layout

---

## 4. Content Resilience

- [ ] Long text strings handled gracefully (truncation, wrapping, or scrolling)
- [ ] Missing images handled with fallback placeholder or background color
- [ ] Empty states designed and implemented for data-less scenarios
- [ ] Short content does not collapse layout or create awkward gaps
- [ ] Dynamic content length variations do not break visual alignment
- [ ] Multi-language text length differences accounted for (German ~30% longer)

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Result | APPROVED / BLOCKED |
| Notes | |
