# Architecture Review Checklist — Apex Squad

> Reviewer: frontend-arch
> Purpose: Validate architectural decisions and enforce runtime boundaries before merging.
> Usage: Check every item. A single unchecked item blocks approval.

---

## 1. Runtime Boundaries

- [ ] Server/client splits clearly identified in the component tree
- [ ] Every `'use client'` directive is justified with a comment explaining why
- [ ] No `'use client'` at route-level layouts — pushed as far down as possible
- [ ] Edge runtime compatibility verified for middleware and API routes
- [ ] No Node.js-only APIs used in edge-targeted code
- [ ] Server Actions are colocated or in dedicated `actions.ts` files

---

## 2. Bundle Impact

- [ ] New dependencies justified with rationale (no alternatives existed or were inferior)
- [ ] Tree-shaking verified — no barrel imports pulling entire libraries
- [ ] JavaScript budget maintained (first-load JS < 80KB gzipped)
- [ ] No duplicate dependencies introduced (checked with `npm ls` or bundler analysis)
- [ ] Heavy dependencies kept server-side or lazily loaded
- [ ] Dynamic imports used for route-level code splitting

---

## 3. Monorepo Rules

- [ ] Import rules followed — no cross-app imports
- [ ] `packages/` modules do not import from `apps/`
- [ ] No circular dependencies between packages (verified with dependency graph)
- [ ] Shared utilities are in the correct shared package
- [ ] Package boundaries respect the dependency direction (leaf -> shared -> core)
- [ ] `tsconfig.json` paths and references are correctly configured

---

## 4. Performance

- [ ] LCP budget met (< 1.2s on target devices)
- [ ] INP budget met (< 200ms for all interactions)
- [ ] CLS budget met (< 0.1, no layout shifts above fold)
- [ ] No waterfall request regressions introduced
- [ ] Streaming (React Suspense) used where data fetching is slow
- [ ] Critical rendering path reviewed — no render-blocking resources added
- [ ] Prefetching and preloading strategies appropriate

---

## 5. Documentation

- [ ] ADR created for significant architectural decisions
- [ ] Trade-offs documented (why this approach over alternatives)
- [ ] Migration path described if changing existing patterns
- [ ] Breaking changes clearly documented with upgrade instructions
- [ ] Diagram updated if component/module topology changed

---

## Sign-Off

| Field | Value |
|-------|-------|
| Reviewer | |
| Story ID | |
| Date | |
| Result | APPROVED / BLOCKED |
| Notes | |
