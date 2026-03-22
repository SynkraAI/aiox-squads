# RSC Pattern Compliance Checklist — Apex Squad

> Reviewer: frontend-arch
> Purpose: Ensure React Server Components patterns are correctly applied throughout the codebase.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Server Components

- [ ] Components default to server — no `'use client'` unless required
- [ ] Async/await used for data fetching in server components
- [ ] No `useState` or `useEffect` in server components
- [ ] No `useContext` in server components
- [ ] No event handlers (`onClick`, `onChange`, etc.) in server components
- [ ] No browser-only APIs (`window`, `document`, `localStorage`) in server components
- [ ] Server components do not import client-only libraries

---

## 2. Client Boundaries

- [ ] `'use client'` directive used only for components requiring interactivity
- [ ] Client boundaries pushed as far down the component tree as possible
- [ ] Each `'use client'` usage has a justifying comment
- [ ] Client components receive server data via props, not re-fetching
- [ ] No unnecessary client wrappers around server components
- [ ] Client components are small and focused on interactivity

---

## 3. Data Flow

- [ ] No waterfall fetches — parallel data fetching with `Promise.all` or concurrent requests
- [ ] Streaming used for slow data sources via `<Suspense>` boundaries
- [ ] Suspense boundaries defined at meaningful UI boundaries
- [ ] Loading states (skeletons/spinners) provided for each Suspense boundary
- [ ] Error boundaries placed alongside Suspense boundaries
- [ ] No client-side data fetching for data available at request time
- [ ] Server Actions used for mutations instead of API routes where appropriate

---

## 4. Bundle

- [ ] Server-only dependencies not leaked into client bundle
- [ ] `server-only` package used to guard server-only modules
- [ ] Heavy computation libraries kept server-side
- [ ] Client bundle analyzed — no unexpected server code included
- [ ] Third-party components wrapped in client boundary only when necessary
- [ ] Shared utilities split into server/client versions if needed

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Result | APPROVED / BLOCKED |
| Notes | |
