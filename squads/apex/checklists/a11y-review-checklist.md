# Accessibility Review Checklist — Apex Squad

> Reviewer: a11y-eng
> Purpose: Validate accessibility compliance across semantics, keyboard, screen reader, visual, and motion.
> Usage: Check every item. A single unchecked item blocks approval.

> **Scope:** Practical accessibility review by @a11y-eng covering **keyboard navigation, screen reader testing, focus management, ARIA patterns, and color contrast**. Action-oriented items for hands-on testing.
> **Use when:** Performing hands-on accessibility audit of a feature.
> **Related:** `wcag-22-checklist.md` (comprehensive WCAG 2.2 criterion-by-criterion compliance check).

---

## 1. Semantics

- [ ] Correct HTML elements used (e.g., `<button>` not `<div onClick>`)
- [ ] ARIA roles used only when native HTML semantics are insufficient
- [ ] Heading hierarchy is logical and sequential (h1 -> h2 -> h3, no skipped levels)
- [ ] Landmarks used appropriately (`<main>`, `<nav>`, `<aside>`, `<header>`, `<footer>`)
- [ ] Lists use `<ul>`/`<ol>`/`<li>` — not styled divs
- [ ] Tables use `<table>`, `<thead>`, `<th>` with `scope` for data presentation
- [ ] Form elements use `<fieldset>` and `<legend>` for grouped controls

---

## 2. Keyboard

- [ ] All interactive elements are focusable via Tab key
- [ ] Logical tab order follows visual reading order
- [ ] No keyboard traps — user can always Tab/Shift+Tab out
- [ ] ESC key closes overlays, modals, and dropdowns
- [ ] Enter/Space activates buttons and links
- [ ] Arrow keys navigate within composite widgets (tabs, menus, radio groups)
- [ ] Focus is moved to modal on open and returned to trigger on close
- [ ] Skip navigation link is available and functional

---

## 3. Screen Reader

- [ ] Meaningful alt text on informative images
- [ ] `aria-label` on icon-only buttons (e.g., close, menu, search)
- [ ] Live regions (`aria-live`) used for dynamic content updates (toasts, notifications)
- [ ] Form labels properly associated with inputs (`<label htmlFor>` or `aria-labelledby`)
- [ ] Error messages associated with form fields via `aria-describedby`
- [ ] Decorative images have `alt=""` and `aria-hidden="true"`
- [ ] Screen reader tested (VoiceOver on Mac/iOS, NVDA or JAWS on Windows, TalkBack on Android)
- [ ] Reading order matches visual order

---

## 4. Visual

- [ ] Text contrast meets 4.5:1 ratio (WCAG AA for normal text)
- [ ] UI component contrast meets 3:1 ratio (borders, icons, focus indicators)
- [ ] Focus indicators are visible and meet 3:1 contrast against adjacent colors
- [ ] Color is not the sole means of conveying information
- [ ] Content readable at 200% browser zoom without horizontal scrolling
- [ ] Text spacing adjustable without loss of content (WCAG 1.4.12)
- [ ] No content hidden behind or overlapping other content at any zoom level

---

## 5. Motion

- [ ] `prefers-reduced-motion` respected for all non-essential animations
- [ ] No autoplay video or audio — or controls provided to pause/stop
- [ ] Pause, stop, or hide controls available for any moving content
- [ ] Flashing content does not exceed 3 flashes per second
- [ ] Scrolling animations can be paused by the user

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Tools Used | axe / VoiceOver / NVDA / Lighthouse |
| Result | APPROVED / BLOCKED |
| Notes | |
