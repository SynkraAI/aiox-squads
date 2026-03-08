# Interaction Accessibility Checklist — Apex Squad

> Reviewer: interaction-dsgn
> Purpose: Validate that interactive elements are accessible across input methods and ability levels.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Touch Targets

- [ ] All interactive elements are at least 44x44px touch target size
- [ ] Adequate spacing between adjacent touch targets (minimum 8px gap)
- [ ] Small visual elements have expanded hit area via padding or `::after` pseudo-element
- [ ] Touch targets do not overlap — no accidental taps on wrong element
- [ ] Inline links within text have sufficient vertical padding for touch
- [ ] Close buttons and dismiss actions are easily tappable

---

## 2. Focus

- [ ] `focus-visible` styles defined for all interactive elements
- [ ] Focus indicator has sufficient contrast (3:1 against adjacent colors)
- [ ] Focus indicator is at least 2px thick and clearly visible
- [ ] Logical tab order follows visual reading order
- [ ] No focus traps — user can always tab out of any component
- [ ] Focus is managed correctly on modal open/close (moves to modal, returns on dismiss)
- [ ] Skip-to-content link provided for keyboard users
- [ ] Custom focus styles do not hide the default when `focus-visible` is not supported

---

## 3. Motion

- [ ] `prefers-reduced-motion` media query respected for all animations
- [ ] Essential motion (functional feedback) preserved under reduced motion
- [ ] Decorative motion fully suppressed under reduced motion
- [ ] No autoplay animations — or autoplay respects reduced motion preference
- [ ] Parallax effects disabled under reduced motion
- [ ] Animation duration does not exceed 5 seconds without user control

---

## 4. Color

- [ ] Color is not the sole indicator of state (error, success, active, etc.)
- [ ] Icons, text labels, or patterns used alongside color indicators
- [ ] Sufficient contrast between interactive states (default vs hover vs active)
- [ ] Component works in high-contrast mode (`forced-colors: active`)
- [ ] Selected/active states distinguishable without color (e.g., border, weight, icon)
- [ ] Error states include text message, not just red border

---

## 5. Pointer Alternatives

- [ ] Drag-and-drop has keyboard alternative (arrow keys or explicit move action)
- [ ] Swipe gestures have button alternatives
- [ ] Hover-revealed content also accessible via focus or click
- [ ] Right-click context menus have alternative access method
- [ ] Multi-finger gestures have single-pointer alternatives

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Result | APPROVED / BLOCKED |
| Notes | |
