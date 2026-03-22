# Task: rsc-boundary-audit

```yaml
id: rsc-boundary-audit
version: "1.0.0"
title: "RSC Boundary Audit"
description: >
  Audit React Server Component and Client Component boundaries across
  the codebase. Identifies unnecessary 'use client' directives, finds
  components that could be moved to the server, calculates the client
  JS impact of current boundaries, and recommends optimizations.
elicit: false
owner: frontend-arch
executor: frontend-arch
outputs:
  - RSC boundary audit report
  - Client JS impact analysis
  - Boundary optimization recommendations
  - List of components that could be server components
```

---

## When This Task Runs

This task runs when:
- New components are being added and need boundary classification
- Performance budget review flags excessive client-side JS
- A feature moves from prototype to production and needs RSC optimization
- A periodic audit of component boundaries is scheduled
- A developer is unsure whether a component should be server or client

This task does NOT run when:
- The component is clearly interactive (forms, modals, tooltips) — it needs `'use client'`
- The question is about component API design (route to `@design-sys-eng`)
- The concern is about animation behavior (route to `@motion-eng`)

---

## RSC Boundary Principles

```yaml
principles:
  default_server: "Components are server components by default — only add 'use client' when necessary"
  push_down: "Push 'use client' as far down the tree as possible"
  composition: "Prefer composition (server parent, client child) over full client subtrees"
  no_unnecessary_client: "Never use 'use client' just for convenience — justify each one"

client_required_when:
  - "Component uses useState, useReducer, or other state hooks"
  - "Component uses useEffect, useLayoutEffect"
  - "Component uses event handlers (onClick, onChange, etc.)"
  - "Component uses browser-only APIs (window, document, IntersectionObserver)"
  - "Component uses third-party libraries that require client context"
  - "Component uses useContext for client-side state"

client_NOT_required_for:
  - "Fetching data (use server components or server actions)"
  - "Rendering static or dynamic content without interactivity"
  - "Layout components that only compose children"
  - "Components that only use server-side hooks (cookies(), headers())"
```

---

## Execution Steps

### Step 1: Scan for 'use client' Directives

Inventory all client component boundaries:

1. Search for all files containing `'use client'` or `"use client"` directives
2. Record the file path, component name, and location in the component tree
3. Group by feature/route to understand the client boundary topology
4. Count total client components vs server components
5. Map the client boundary tree depth (how far up the tree do client boundaries reach?)

### Step 2: Check Justification for Each Directive

Analyze whether each `'use client'` is necessary:

1. For each client component, identify WHY it is a client component:
   - Uses state hooks → **Justified**
   - Uses effects → **Justified** (but check if replaceable with server action)
   - Uses event handlers → **Justified** (but check if composable)
   - Uses browser APIs → **Justified**
   - Uses a client-only library → **Justified** (but flag for potential replacement)
   - No clear reason found → **Unjustified** — candidate for conversion
2. Rate each: NECESSARY / OPTIMIZABLE / UNJUSTIFIED
3. For OPTIMIZABLE components, note what pattern change would remove the directive

### Step 3: Identify Server-Eligible Components

Find components currently marked as client that could be server:

1. Components that only render props without interactivity
2. Components that fetch data and could use server-side fetching
3. Components where the `'use client'` was added for a child, but the parent itself is static
4. Layout wrappers that only provide CSS structure
5. For each candidate, document:
   - Current client reason
   - Proposed server pattern
   - Refactoring steps needed

### Step 4: Calculate Client JS Impact

Quantify the JavaScript cost of current boundaries:

1. Run bundle analysis per route to get client JS breakdown
2. For each client boundary, estimate its contribution to the bundle:
   - Component code size (gzipped)
   - Dependencies pulled into the client bundle
   - Shared chunks created by the boundary
3. Calculate total client JS that could be eliminated by converting candidates
4. Compare against the JS budget (< 80KB first-load)
5. Rank client components by JS impact (highest cost first)

### Step 5: Recommend Boundary Optimizations

Propose specific changes to optimize boundaries:

1. **Convert to server** — list components that can drop `'use client'`
2. **Split and compose** — identify components where extracting the interactive part
   into a smaller client component would reduce the boundary scope
3. **Lazy load** — identify client components that are below the fold and can be
   dynamically imported
4. **Replace library** — flag client-only libraries with server-compatible alternatives
5. For each recommendation, estimate the JS savings (KB gzipped)
6. Prioritize by impact-to-effort ratio

---

## Output Format

```markdown
# RSC Boundary Audit

**Date:** {YYYY-MM-DD}
**Auditor:** @frontend-arch
**Scope:** {routes or packages audited}

## Summary
- Total components scanned: {N}
- Server components: {N} ({%})
- Client components: {N} ({%})
- Unjustified client components: {N}
- Estimated recoverable JS: {KB} gzipped

## Client Boundary Map
{Tree visualization of 'use client' boundaries}

## Findings

### Unjustified Client Components
| Component | File | Reason Flagged | Recommended Action |
|-----------|------|----------------|-------------------|

### Optimizable Components
| Component | Current Cost | Savings | Refactoring |
|-----------|-------------|---------|-------------|

### Justified Client Components
| Component | Reason | Cost |
|-----------|--------|------|

## Recommendations
{Prioritized list from Step 5}

## Verdict: {OPTIMAL | NEEDS OPTIMIZATION | EXCESSIVE CLIENT JS}
```

---

*Apex Squad — RSC Boundary Audit Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-rsc-boundary-audit
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (PASS/FAIL/NEEDS_WORK)"
    - "Every 'use client' directive must be classified as NECESSARY, OPTIMIZABLE, or UNJUSTIFIED"
    - "Client JS impact must be quantified per route with comparison against JS budget"
    - "Optimization recommendations must include estimated JS savings in KB"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | RSC boundary audit report with client JS impact analysis, boundary optimization recommendations, and list of server-eligible components |
| Next action | Route optimizations to `@react-eng` for boundary restructuring or to `@perf-eng` for bundle optimization |
