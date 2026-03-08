# Task: apex-suggest

```yaml
id: apex-suggest
version: "1.0.0"
title: "Apex Proactive Suggestions"
description: >
  After any Apex operation (fix, quick, pipeline), the squad analyzes the
  changed files and surrounding context for issues the user might not have
  noticed. Suggests improvements but NEVER executes without explicit permission.
elicit: true
owner: apex-lead
executor: apex-lead
dependencies:
  - tasks/apex-scan.md
  - data/veto-conditions.yaml
outputs:
  - Prioritized list of suggestions (0-5 items)
  - Each suggestion with severity, agent, and one-line fix description
```

---

## Command

### `*apex-suggest`

Manually trigger a suggestion scan on the current codebase. Also runs automatically (silent) after every `*apex-fix` and `*apex-quick` completion.

---

## When Suggestions Run

### Automatic (post-operation)

After `*apex-fix`, `*apex-quick`, `*apex-go`, `*discover-components`, or `*discover-design` completes, apex-lead silently scans for issues. If found, appends suggestions to the completion report.

**After discovery (enriched suggestions):**
- `*discover-components` feeds: orphaned components, untested components, god components, missing Error Boundaries
- `*discover-design` feeds: hardcoded color violations, spacing outliers, near-duplicate colors, z-index chaos

Discovery data replaces guessing with exact file paths and values.

### Manual (`*apex-suggest`)

User explicitly asks for a full-project suggestion scan. Scans all components, not just recently modified files.

### On Activation (first time)

When Apex activates for the first time in a project (detected via `*apex-scan`), run a lightweight suggestion scan and present top 3 findings.

---

## Detection Rules

### A11y Issues (@a11y-eng domain)

```yaml
a11y_checks:
  - id: SUG-A11Y-001
    name: "Missing alt text"
    detect: "<img without alt= OR alt=\"\""
    severity: high
    suggestion: "Add descriptive alt text to images"

  - id: SUG-A11Y-002
    name: "Low contrast text"
    detect: "text-gray-400, text-slate-400, text-zinc-400 on light backgrounds"
    severity: high
    suggestion: "Increase text contrast to meet WCAG AA (4.5:1 ratio)"

  - id: SUG-A11Y-003
    name: "Missing form labels"
    detect: "<input without associated <label> or aria-label"
    severity: high
    suggestion: "Add labels to all form inputs"

  - id: SUG-A11Y-004
    name: "Missing keyboard navigation"
    detect: "onClick on non-interactive element (div, span) without tabIndex/role"
    severity: medium
    suggestion: "Add keyboard support (tabIndex, onKeyDown, role='button')"

  - id: SUG-A11Y-005
    name: "Missing skip link"
    detect: "No skip-to-content link in layout"
    severity: low
    suggestion: "Add skip-to-main-content link for keyboard users"

  - id: SUG-A11Y-006
    name: "Missing reduced-motion"
    detect: "motion.div or useSpring without prefers-reduced-motion check"
    severity: medium
    suggestion: "Add prefers-reduced-motion media query"
```

### Performance Issues (@perf-eng domain)

```yaml
perf_checks:
  - id: SUG-PERF-001
    name: "Large image without optimization"
    detect: "<img src= without width/height or loading='lazy'"
    severity: medium
    suggestion: "Add loading='lazy' and explicit dimensions"

  - id: SUG-PERF-002
    name: "Missing code splitting"
    detect: "import {Component} from (not using React.lazy)"
    scope: "Route-level components only"
    severity: medium
    suggestion: "Use React.lazy() for route-level code splitting"

  - id: SUG-PERF-003
    name: "Unnecessary re-renders"
    detect: "Component creates new objects/arrays in render (inline {} or [])"
    severity: low
    suggestion: "Extract constant objects outside component or use useMemo"

  - id: SUG-PERF-004
    name: "Heavy dependency in bundle"
    detect: "moment, lodash (full), date-fns (full import)"
    severity: medium
    suggestion: "Replace with lighter alternative or tree-shake"

  - id: SUG-PERF-005
    name: "Missing font optimization"
    detect: "Google Fonts via <link> instead of next/font or @font-face with display:swap"
    severity: low
    suggestion: "Use font-display: swap or self-host fonts"
```

### CSS Anti-patterns (@css-eng domain)

```yaml
css_checks:
  - id: SUG-CSS-001
    name: "Hardcoded color values"
    detect: "text-[#...], bg-[#...], or inline style with hex colors"
    severity: medium
    suggestion: "Use CSS variables or Tailwind theme colors"

  - id: SUG-CSS-002
    name: "Magic number spacing"
    detect: "p-[13px], m-[7px], gap-[11px] (non-standard spacing)"
    severity: low
    suggestion: "Use Tailwind's spacing scale (multiples of 4px)"

  - id: SUG-CSS-003
    name: "Missing responsive breakpoints"
    detect: "Fixed widths (w-[500px]) without responsive variants"
    severity: medium
    suggestion: "Add sm:/md:/lg: variants for mobile compatibility"

  - id: SUG-CSS-004
    name: "Inconsistent border radius"
    detect: "Mix of rounded-sm, rounded-md, rounded-lg, rounded-xl in same section"
    severity: low
    suggestion: "Standardize border radius per component type"

  - id: SUG-CSS-005
    name: "Z-index chaos"
    detect: "z-[999], z-[9999], z-[99999] — unmanaged z-index"
    severity: medium
    suggestion: "Define z-index scale in CSS variables or Tailwind config"
```

### Motion Issues (@motion-eng domain)

```yaml
motion_checks:
  - id: SUG-MOT-001
    name: "CSS transition instead of spring"
    detect: "transition-all, transition-transform (CSS transitions for UI motion)"
    severity: low
    suggestion: "Consider spring animation for more natural feel"

  - id: SUG-MOT-002
    name: "Too many simultaneous animations"
    detect: "> 5 motion.div elements animating on same viewport"
    severity: medium
    suggestion: "Stagger animations or reduce animation count for performance"

  - id: SUG-MOT-003
    name: "Missing exit animation"
    detect: "AnimatePresence without exit prop on children"
    severity: low
    suggestion: "Add exit animation for smoother unmount transitions"
```

### React Patterns (@react-eng domain)

```yaml
react_checks:
  - id: SUG-REACT-001
    name: "Missing error boundary"
    detect: "No ErrorBoundary component wrapping route-level components"
    severity: medium
    suggestion: "Add ErrorBoundary for graceful error handling"

  - id: SUG-REACT-002
    name: "Prop drilling (>3 levels)"
    detect: "Same prop passed through 3+ component levels"
    severity: low
    suggestion: "Consider React Context or composition pattern"

  - id: SUG-REACT-003
    name: "Missing key in list"
    detect: ".map() rendering elements without key prop"
    severity: high
    suggestion: "Add unique key prop to list items"
```

---

## Output Format

### Post-operation (automatic, appended to report)

```
SUGGESTIONS ({count} found)
----------------------------
 HIGH  [A11Y] Missing alt text on 2 images — @a11y-eng can fix
 MED   [PERF] Images without loading="lazy" — @perf-eng can fix
 MED   [CSS]  Hardcoded hex #1a1a2e in Header.tsx — @css-eng can fix
 LOW   [MOT]  CSS transition used in Modal.tsx — @motion-eng can improve

Apply a suggestion? Type the number or "skip".
```

### Manual scan (`*apex-suggest`)

```
APEX SUGGESTION SCAN
=====================

Scanned: 12 components, 3 pages, 1 layout
Found: 7 suggestions (2 high, 3 medium, 2 low)

HIGH PRIORITY
--------------
1. [A11Y] SUG-A11Y-002 — Low contrast text in ServiceCard.tsx
   text-slate-400 on white background (ratio ~3.5:1, needs 4.5:1)
   Fix: Change to text-slate-700 — @a11y-eng

2. [REACT] SUG-REACT-003 — Missing key in services list
   src/pages/Servicos.tsx line 42: .map() without key
   Fix: Add key={service.id} — @react-eng

MEDIUM PRIORITY
----------------
3. [CSS] SUG-CSS-001 — Hardcoded colors in 3 files
   Header.tsx, Footer.tsx, Hero.tsx use inline hex values
   Fix: Extract to CSS variables — @css-eng

4. [PERF] SUG-PERF-001 — 4 images without lazy loading
   Servicos.tsx has 4 <img> without loading="lazy"
   Fix: Add loading="lazy" and dimensions — @perf-eng

5. [CSS] SUG-CSS-003 — Fixed width in ScheduleForm
   w-[480px] without responsive variant
   Fix: Add max-w-lg w-full — @css-eng

LOW PRIORITY
-------------
6. [MOT] SUG-MOT-001 — CSS transition in Footer.tsx
   transition-colors used instead of spring
   Fix: Optional — replace with motion hover — @motion-eng

7. [CSS] SUG-CSS-002 — Magic spacing p-[13px]
   ScheduleForm.tsx uses non-standard spacing
   Fix: Change to p-3 (12px) or p-3.5 (14px) — @css-eng

=====================
Apply suggestions? Options:
  - "fix 1" — Apply suggestion #1 via *apex-fix
  - "fix 1,2,3" — Apply multiple via *apex-quick
  - "fix all high" — Apply all HIGH priority
  - "skip" — Dismiss suggestions
```

---

## Interaction Rules

```yaml
rules:
  - NEVER auto-fix suggestions — always present and wait for user decision
  - NEVER block operations because of suggestions — they are informational
  - Limit to 5 suggestions per automatic scan (post-operation)
  - Limit to 10 suggestions per manual scan (*apex-suggest)
  - Sort by severity: HIGH > MEDIUM > LOW
  - Within same severity, sort by impact (more files affected first)
  - If zero suggestions found, say "No issues detected" (don't fabricate)
  - User can apply suggestions via *apex-fix (single) or *apex-quick (batch)
  - Suggestions persist until fixed or dismissed — don't re-suggest the same issue
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | User (suggestion list) |
| Next action | User picks suggestions to fix, or skips |

---

*Apex Squad — Proactive Suggestions Task v1.0.0*
