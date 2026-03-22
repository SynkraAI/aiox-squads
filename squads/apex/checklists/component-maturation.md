# Component Promotion Criteria Checklist — Apex Squad

> Reviewer: design-sys-eng
> Purpose: Validate that a component meets all criteria for promotion to the next maturity level.
> Usage: Check every item for the target promotion level. A single unchecked item blocks promotion.

---

## 1. Experimental to Alpha

- [ ] Component solves a validated real-world need (not speculative)
- [ ] Basic implementation is functional and renders without errors
- [ ] Used in at least 1 application or prototype
- [ ] Basic Storybook stories exist (default state, key variations)
- [ ] Component has a clear owner and responsible team
- [ ] Props interface defined (may be unstable)
- [ ] No known critical bugs or crashes

---

## 2. Alpha to Beta

- [ ] API is stable — no breaking prop changes planned
- [ ] Full unit test coverage for all props and states
- [ ] Integration tests for key user interactions
- [ ] Used in 3 or more applications successfully
- [ ] All modes supported (light, dark, high-contrast)
- [ ] Accessibility audit passed (keyboard, screen reader, contrast)
- [ ] Storybook documentation complete (all props, all states, usage guidelines)
- [ ] TypeScript types are strict and well-documented
- [ ] Error states and edge cases handled gracefully
- [ ] Performance profiled — no unnecessary re-renders

---

## 3. Beta to Stable

- [ ] Performance benchmarked against budgets (render time, bundle size)
- [ ] Cross-platform verified (web browsers, mobile if applicable)
- [ ] Production use for 2+ sprints with no critical issues reported
- [ ] Zero open accessibility issues
- [ ] API guaranteed stable — breaking changes require major version bump
- [ ] Migration guide written for consumers upgrading from previous versions
- [ ] Semantic versioning applied to the component package
- [ ] Visual regression tests in place and passing
- [ ] Peer reviewed by at least 2 engineers outside the authoring team
- [ ] Component listed in the design system catalog with full documentation

---

## 4. Deprecation Criteria

- [ ] Replacement component identified and documented
- [ ] Migration path clearly documented with code examples
- [ ] Deprecation warning added to Storybook and JSDoc
- [ ] Consumers notified with timeline for removal
- [ ] Usage metrics show majority migrated to replacement

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Component Name | |
| Current Level | Experimental / Alpha / Beta |
| Target Level | Alpha / Beta / Stable |
| Date | |
| Result | PROMOTED / BLOCKED |
| Notes | |
