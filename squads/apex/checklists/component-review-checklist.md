# React Component Code Review Checklist — Apex Squad

> Reviewer: react-eng
> Purpose: Review React components for composition, state management, performance, and testing quality.
> Usage: Check every item. A single unchecked item blocks approval.

> **Scope:** React engineering patterns checklist used by @react-eng. Focuses on **hooks, state management, rendering patterns, server components, and React-specific best practices**.
> **Use when:** Reviewing React implementation patterns of a component.
> **Related:** `component-quality-checklist.md` (general quality), `ds-component-review.md` (design system compliance).

---

## 1. Composition

- [ ] No prop drilling — context, composition, or state management used instead
- [ ] Compound/slot pattern used where component has multiple configurable regions
- [ ] Component has fewer than 8 props (complexity signal — consider splitting)
- [ ] Children pattern preferred over render props where possible
- [ ] Component is focused on a single responsibility
- [ ] Reusable components extracted from page-level components where appropriate
- [ ] No hasty abstractions — duplication preferred over premature generalization

---

## 2. State

- [ ] State correctly categorized: server state, UI state, form state, or URL state
- [ ] State colocated with the component that uses it — not lifted prematurely
- [ ] Server state managed with React Query / SWR / server components (not local `useState`)
- [ ] URL state used for shareable/bookmarkable UI state (filters, tabs, pagination)
- [ ] Form state managed with a form library or server actions
- [ ] No derived state stored in `useState` — computed inline or with `useMemo`
- [ ] No `useEffect` for state synchronization — refactored to event handlers

---

## 3. Server Components

- [ ] Server component by default — `'use client'` only when needed
- [ ] `'use client'` justified with a comment explaining the requirement
- [ ] No unnecessary `useEffect` for data fetching — server components handle it
- [ ] Server Actions used for form submissions and mutations
- [ ] Client component boundary pushed as far down the tree as possible
- [ ] Props serializable across the server/client boundary (no functions passed down)

---

## 4. Testing

- [ ] User behavior tested — not implementation details
- [ ] `getByRole` and `getByLabelText` preferred over `getByTestId`
- [ ] No testing of internal state or private methods
- [ ] Async operations properly awaited in tests (`waitFor`, `findBy`)
- [ ] Edge cases covered (empty state, error state, loading state)
- [ ] Accessibility assertions included (`toBeAccessible` or axe checks)
- [ ] Snapshot tests used sparingly and with purpose (not as primary strategy)

---

## 5. Performance

- [ ] `React.memo` used only when measured improvement confirmed
- [ ] `useMemo` / `useCallback` applied only for expensive computations or stable references
- [ ] No premature optimization — profile first, optimize second
- [ ] Key props correctly set on lists (stable, unique identifiers)
- [ ] Large lists use virtualization (react-window, react-virtuoso, etc.)
- [ ] Images below the fold are lazy loaded
- [ ] No unnecessary re-renders verified with React DevTools Profiler

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Result | APPROVED / BLOCKED |
| Notes | |
