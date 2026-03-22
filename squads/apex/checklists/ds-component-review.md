# Design System Component Review Checklist — Apex Squad

> Reviewer: design-sys-eng
> Purpose: Review design system components for token compliance, API quality, mode support, and documentation.
> Usage: Check every item. A single unchecked item blocks approval.

> **Scope:** Design system compliance checklist used by @design-sys-eng. Focuses on **token usage, naming conventions, theming, and design system governance**.
> **Use when:** Reviewing a component for design system integration and token compliance.
> **Related:** `component-quality-checklist.md` (general quality), `component-review-checklist.md` (React patterns).

---

## 1. Tokens

- [ ] All visual values reference design tokens — zero hardcoded values
- [ ] Correct token layer hierarchy used (primitive -> semantic -> component)
- [ ] Component tokens override semantic tokens where needed via CSS custom properties
- [ ] Token fallback values defined for resilience
- [ ] No tokens bypassing the semantic layer (component should not reference primitives directly)
- [ ] Token usage verified in browser DevTools (computed values match expectations)

---

## 2. API

- [ ] Clean props interface with TypeScript types
- [ ] Props are well-named and self-documenting
- [ ] Fewer than 8 required props (complexity check)
- [ ] Default values provided for optional props
- [ ] Slot pattern or render props used for composition where needed
- [ ] Component accepts `className` and `style` for escape-hatch customization
- [ ] Ref forwarding implemented correctly
- [ ] Documented in Storybook with interactive controls

---

## 3. Modes

- [ ] Light mode renders correctly with all states
- [ ] Dark mode renders correctly with all states
- [ ] High-contrast mode renders correctly with all states
- [ ] Mode-specific Storybook stories exist for visual verification
- [ ] No hardcoded colors that break in alternate modes
- [ ] Token values verified visually in each mode

---

## 4. States

- [ ] Default state styled and visually correct
- [ ] Hover state styled with appropriate feedback
- [ ] Active/pressed state styled with appropriate feedback
- [ ] Focus state styled with visible focus indicator
- [ ] Disabled state styled with reduced opacity or muted appearance
- [ ] Loading state implemented if applicable (skeleton or spinner)
- [ ] Error state implemented if applicable (visual indicator + message)
- [ ] Selected/active state distinct from default

---

## 5. Documentation

- [ ] Storybook stories cover all props and variations
- [ ] Usage guidelines written (when to use, when not to use)
- [ ] Slot patterns documented with examples
- [ ] Accessibility notes included (keyboard behavior, ARIA attributes)
- [ ] Do/Don't examples provided for common misuse patterns
- [ ] Changelog maintained for breaking changes

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Component Name | |
| Story ID | |
| Date | |
| Result | APPROVED / BLOCKED |
| Notes | |
