# Visual QA Checklist — Apex Squad

> Reviewer: qa-visual
> Purpose: Validate pixel fidelity, responsive behavior, mode support, states, and typography accuracy.
> Usage: Check every item. A single unchecked item blocks approval.

> **Scope:** Visual regression testing by **@qa-visual** during the QA phase. Focuses on **screenshot comparison, cross-browser rendering, responsive breakpoints, theme modes, component states**.
> **Use when:** Running visual regression tests before shipping (QA gate QG-AX-008).
> **Related:** `visual-review-checklist.md` (design fidelity review by apex-lead during design phase).

---

## 1. Pixel Fidelity

- [ ] Implementation matches Figma design within 1px tolerance
- [ ] Spacing values align with 4px grid system
- [ ] Correct design tokens used (verified in DevTools computed styles)
- [ ] Element dimensions match Figma specifications
- [ ] Border radius values match design spec
- [ ] Shadow/elevation values match design spec
- [ ] Icon sizes and alignment match Figma

---

## 2. Responsive

- [ ] 320px (mobile-s) tested — no overflow, content readable
- [ ] 375px (standard mobile) tested — layout correct
- [ ] 768px (tablet) tested — breakpoint triggers correctly
- [ ] 1024px (small desktop) tested — layout adapts
- [ ] 1280px (standard desktop) tested — primary layout correct
- [ ] 1920px (FHD) tested — no stretching or excessive whitespace
- [ ] 2560px (QHD/4K) tested — content well-proportioned
- [ ] No horizontal scrollbar at any viewport size
- [ ] Content does not overflow containers at any size

---

## 3. Modes

- [ ] Light mode renders all elements correctly
- [ ] Dark mode renders all elements correctly
- [ ] High-contrast mode renders all elements correctly
- [ ] No flash of wrong theme on initial load or mode switch
- [ ] Mode switch does not cause layout shift
- [ ] All color combinations maintain required contrast in each mode

---

## 4. States

- [ ] Hover state visually distinct and correct per design
- [ ] Active/pressed state visually distinct and correct per design
- [ ] Focus state has visible focus indicator meeting contrast requirements
- [ ] Disabled state appears muted/inactive — clearly not interactive
- [ ] Loading state shows skeleton or spinner per design
- [ ] Empty state designed and implemented — not blank screen
- [ ] Error state shows visual indicator and error message
- [ ] Selected/active state distinct from default state

---

## 5. Typography

- [ ] Correct font family applied (verified in DevTools)
- [ ] Font sizes match design spec at each breakpoint
- [ ] Font weights match design spec (regular, medium, semibold, bold)
- [ ] Line heights match design spec
- [ ] Letter spacing matches design spec where defined
- [ ] No orphans or widows in key headline layouts
- [ ] Text truncation with ellipsis works where specified
- [ ] Heading hierarchy visually clear and semantically correct

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Figma Link | |
| Browsers Tested | |
| Result | APPROVED / BLOCKED |
| Notes | |
