# Defensive CSS Pattern Checklist — Apex Squad

> Reviewer: interaction-dsgn
> Purpose: Ensure CSS is resilient against unexpected content, edge cases, and layout failures.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Text

- [ ] `overflow-wrap: break-word` set on text containers to prevent overflow from long words/URLs
- [ ] `text-overflow: ellipsis` applied where single-line truncation is needed
- [ ] `min-height` set for multiline text containers to prevent collapse
- [ ] `hyphens: auto` considered for justified or narrow text columns
- [ ] Long unbroken strings (emails, URLs, IDs) do not overflow their containers
- [ ] Text remains readable at 200% browser zoom level

---

## 2. Images

- [ ] `object-fit: cover` or `object-fit: contain` set on all images
- [ ] `max-width: 100%` applied to prevent images from overflowing containers
- [ ] `aspect-ratio` fallback defined to prevent layout shift during load
- [ ] Background color placeholder set for images that may fail to load
- [ ] `alt` text provided — empty `alt=""` only for decorative images
- [ ] SVG images have explicit `width` and `height` or `viewBox`

---

## 3. Layout

- [ ] `min-width: 0` set on flex items to prevent content overflow
- [ ] `min-width: 0` set on grid items to prevent content overflow
- [ ] `overflow: hidden` or `overflow: auto` applied where content may exceed bounds
- [ ] No implicit stacking contexts created unintentionally (check `position`, `opacity`, `transform`)
- [ ] `isolation: isolate` used where stacking context is intentional
- [ ] Flex and grid containers handle 0 children gracefully (empty state)

---

## 4. Spacing

- [ ] No negative margin hacks — refactored to use proper layout techniques
- [ ] `gap` used instead of `margin` for spacing between flex/grid children
- [ ] Logical properties used for internationalization (`margin-inline`, `padding-block`)
- [ ] Spacing tokens used consistently — no magic numbers
- [ ] Last-child margin/padding does not create unwanted whitespace
- [ ] `safe` keyword considered for `align-items`/`justify-content` to prevent content loss

---

## 5. Scrolling

- [ ] `overscroll-behavior: contain` used on scroll containers to prevent scroll chaining
- [ ] Scroll containers have visible scrollbar or scroll indicators
- [ ] `scrollbar-gutter: stable` used to prevent layout shift when scrollbar appears
- [ ] Touch scrolling is smooth (`-webkit-overflow-scrolling: touch` or equivalent)

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Result | APPROVED / BLOCKED |
| Notes | |
