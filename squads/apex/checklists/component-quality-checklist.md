# Component Quality Checklist — Apex Squad

> Purpose: Validate every new component before it is considered mergeable.
> Owner: @dev (self-review) + apex-lead (final review)
> Trigger: Any new component or significant refactor of an existing component.

> **Scope:** General component quality checklist used during **implementation** by @dev and final review by apex-lead. Covers props API, variants, responsive behavior, dark mode, Storybook, and unit tests.
> **Use when:** Completing implementation of any new component.
> **Related:** `ds-component-review.md` (design system token compliance), `component-review-checklist.md` (React patterns and hooks).

---

## 1. Props Interface (TypeScript Strict)

- [ ] Props interface defined with `interface` (not `type` unless union required)
- [ ] Every prop has an explicit TypeScript type — no `any`, no `unknown` without narrowing
- [ ] Optional props use `?` and have a defined `defaultProps` or default parameter value
- [ ] Required props have no default — absence causes a compile-time error
- [ ] Discriminated unions used for mutually exclusive prop sets
- [ ] Event handler props typed with React event types (`React.MouseEvent<HTMLButtonElement>`, etc.)
- [ ] Children typed explicitly (`React.ReactNode` or specific type — not implicit)
- [ ] `ref` forwarding implemented via `forwardRef` where the element needs to be referenced by parent
- [ ] Prop names follow the codebase naming convention (no abbreviations without precedent)
- [ ] No prop drilling beyond 2 levels — use composition or context instead
- [ ] Props interface exported from the component file

---

## 2. Variants Documented

- [ ] All visual variants defined using CVA (`cva()`) or equivalent variant system
- [ ] Variant names match Figma component properties exactly
- [ ] Default variant specified in CVA config
- [ ] Compound variants defined for multi-prop visual combinations
- [ ] `VariantProps<typeof componentVariants>` used to type variant props
- [ ] All variants visible in Storybook (each variant has at minimum one story)
- [ ] Variants do not accept arbitrary string values — use union literals
- [ ] Size variants follow the defined scale (xs, sm, md, lg, xl — no custom sizes)

---

## 3. Responsive Behavior

- [ ] Component reviewed at 320px, 768px, 1280px, and 1920px minimum
- [ ] No fixed pixel widths that cause overflow on mobile
- [ ] Text truncation or wrapping behavior defined and intentional at all breakpoints
- [ ] Touch targets >= 44px at all breakpoints
- [ ] Responsive variant or class applied via Tailwind responsive prefix (`sm:`, `md:`, `lg:`)
- [ ] No hardcoded `@media` queries — use defined Tailwind breakpoint tokens
- [ ] Images inside the component use `next/image` with `fill` or responsive `width`/`height`

---

## 4. Accessibility (a11y)

### ARIA
- [ ] Semantic HTML used as base (no `<div>` where `<button>`, `<a>`, `<input>` is appropriate)
- [ ] `role` attribute added only when semantic HTML is insufficient
- [ ] `aria-label` or `aria-labelledby` on all interactive elements without visible text labels
- [ ] `aria-describedby` used for supplemental descriptions (e.g., hints, error messages)
- [ ] `aria-live` region added for dynamically updated content
- [ ] `aria-expanded`, `aria-selected`, `aria-checked` kept in sync with UI state
- [ ] `aria-disabled` used instead of HTML `disabled` for custom interactive elements
- [ ] `aria-hidden="true"` on all decorative icons and images

### Keyboard
- [ ] All interactive elements focusable via Tab key
- [ ] Custom components implement correct keyboard interaction pattern (ARIA Authoring Practices Guide)
- [ ] Escape key closes overlays, modals, and popovers
- [ ] Arrow keys navigate within composite widgets (menus, listboxes, grids)
- [ ] Enter and Space activate buttons and controls consistently
- [ ] No keyboard trap outside of intentional modal focus lock

### Focus
- [ ] Focus ring is visible on all interactive elements (not removed globally)
- [ ] Focus ring uses design token (`ring.*`) — not browser default unless it passes contrast
- [ ] Focus order matches the visual reading order
- [ ] Focus returns to trigger element when overlay closes

---

## 5. Motion (Enter / Exit / Hover)

- [ ] Enter animation defined using spring config from `motion.spring.*` tokens
- [ ] Exit animation defined (do not skip exit — use AnimatePresence or equivalent)
- [ ] Hover micro-interaction implemented per design spec (scale, color, shadow delta)
- [ ] Press/active state animation implemented (scale down on press)
- [ ] Loading state animation defined if component has async state
- [ ] All animations use `transform` and `opacity` only (no layout-triggering properties)
- [ ] Animation duration uses `motion.duration.*` tokens
- [ ] Stagger delay uses `motion.stagger.*` tokens for list children
- [ ] `prefers-reduced-motion` check implemented — motion conditionally removed or substituted
- [ ] Animations cleaned up on unmount (no memory leaks)

---

## 6. Dark Mode Support

- [ ] Component renders correctly without any style issues in dark mode
- [ ] All colors use semantic tokens (no hardcoded values that invert incorrectly)
- [ ] Border and separator colors use dark-mode-aware tokens
- [ ] Shadows use dark-mode elevation tokens (lighter shadows on dark backgrounds)
- [ ] Images have dark-mode variants or apply correct CSS filter/opacity if needed
- [ ] Verified in browser with `prefers-color-scheme: dark` via DevTools emulation
- [ ] Dark mode class (`.dark`) applied via Tailwind dark variant — no manual class injection

---

## 7. Storybook Story

- [ ] Story file created at `{ComponentName}.stories.tsx`
- [ ] Default export includes correct `Meta` type with `component` and `title`
- [ ] At least one story per defined variant
- [ ] `Default` story represents the most common use case
- [ ] `args` defined to enable Controls panel interaction
- [ ] `play` function added for interactive stories (simulates user interaction)
- [ ] No hardcoded strings that should come from args
- [ ] Story renders without console errors or prop-type warnings
- [ ] Docs page accurate — description matches component intent
- [ ] Story included in the correct Storybook section (Atoms / Molecules / Organisms / etc.)

---

## 8. Unit Tests

- [ ] Test file created at `{ComponentName}.test.tsx`
- [ ] Renders without crashing (smoke test)
- [ ] Each variant renders correctly (snapshot or assertion)
- [ ] Default props render as expected
- [ ] Required props — missing required prop caught (TypeScript compile-time check documented)
- [ ] Event handlers fire correctly (`userEvent.click`, `userEvent.type`)
- [ ] Keyboard interactions tested (`userEvent.keyboard`)
- [ ] Aria attributes verified in test assertions
- [ ] Async state transitions tested (loading → success, loading → error)
- [ ] Edge cases tested (empty state, max length, zero items, single item)
- [ ] Test coverage >= 80% for component logic (branches covered)
- [ ] No tests that test implementation details (no direct state/internal function access)
- [ ] All tests pass: `pnpm test`

---

## 9. Visual Regression Baseline

- [ ] Chromatic story uploaded and baseline accepted by apex-lead
- [ ] All variant stories have a Chromatic snapshot (not just Default)
- [ ] Dark mode snapshots taken and accepted
- [ ] Mobile viewport snapshot taken and accepted (375px minimum)
- [ ] Hover and focus states captured in Storybook play function for Chromatic
- [ ] Baseline marked as approved in Chromatic dashboard before story merges

---

## Sign-Off

| Field | Value |
|-------|-------|
| Component Name | |
| Story ID | |
| Author (@dev) | |
| Reviewer (apex-lead) | |
| Storybook URL | |
| Chromatic Build | |
| Result | APPROVED / NEEDS WORK |
