# Task: apex-discover-components

```yaml
id: apex-discover-components
version: "1.0.0"
title: "Component Discovery"
description: >
  Scans the project codebase to inventory ALL React components,
  their relationships, usage patterns, test coverage, and health.
  Transforms "let me explore the code" into "I already know every
  component — here's what needs attention."
elicit: false
owner: apex-lead
executor: apex-lead
dependencies:
  - tasks/apex-scan.md
outputs:
  - Complete component inventory with metadata
  - Dependency tree (who imports who)
  - Orphaned components (exported but never imported)
  - Components without tests
  - Components without Error Boundaries
  - Complexity indicators per component
```

---

## Command

### `*discover-components`

Scans the project and inventories all React components. Runs as part of `*apex-audit` or independently.

---

## Discovery Phases

### Phase 1: Scan Component Files

```yaml
file_detection:
  patterns:
    - "src/**/*.tsx"
    - "src/**/*.jsx"
    - "app/**/*.tsx"
    - "components/**/*.tsx"
    - "packages/**/src/**/*.tsx"

  classify:
    page_component:
      detect: "file in app/ or pages/ directory"
      or: "default export with route-level structure"
    layout_component:
      detect: "file named layout.tsx or contains <Outlet/>"
    ui_component:
      detect: "file in components/ or ui/ directory"
      or: "exports a function component with props"
    hook:
      detect: "file starts with use*.ts(x)"
      note: "Track but classify separately"
    utility:
      detect: "file in utils/ or lib/, no JSX"
      note: "Exclude from component count"

  extract_per_component:
    - name: "component name (from export or filename)"
    - path: "relative file path"
    - type: "page | layout | ui | hook"
    - loc: "lines of code"
    - props_interface: "typed (interface/type) | inline | any | none"
    - hooks_used: "list of hooks (useState, useEffect, custom)"
    - has_children: "accepts children prop"
    - has_ref: "uses forwardRef"
    - default_export: "true/false"
    - named_exports: "list of named exports"
```

### Phase 2: Build Dependency Tree

```yaml
dependency_analysis:
  for_each_component:
    scan: "import statements"
    build:
      imports_from: "list of components this component imports"
      imported_by: "list of components that import this one"
      external_deps: "third-party imports (framer-motion, lucide, etc)"

  metrics:
    fan_in: "number of components that import this one"
    fan_out: "number of components this one imports"
    coupling_score: "fan_in + fan_out (high = tightly coupled)"

  detect:
    orphaned:
      definition: "Exported component not imported by any other file"
      exclude: "Page/layout components (they are route entry points)"
      significance: "Dead code candidate"

    circular:
      definition: "A imports B, B imports A (directly or transitively)"
      significance: "Architecture smell, potential infinite re-renders"

    hub_components:
      definition: "Component imported by 10+ other components"
      significance: "High-impact change target, needs extra care"
```

### Phase 3: Assess Quality

```yaml
quality_checks:
  error_boundaries:
    check: "Component tree has Error Boundary coverage"
    detect_missing: "Page/layout components without ErrorBoundary wrapper"
    significance: "Unhandled errors crash the entire app"

  test_coverage:
    scan:
      - "**/*.test.tsx"
      - "**/*.test.ts"
      - "**/*.spec.tsx"
      - "**/*.spec.ts"
      - "__tests__/**/*"
    map: "test file → component file (by naming convention or imports)"
    detect_missing: "Components without any test file"

  typescript_quality:
    detect:
      any_types: "Props typed as 'any' or untyped"
      missing_return: "No explicit return type on component"
      inline_styles: "style={{}} instead of className"

  accessibility_hints:
    detect:
      interactive_no_role: "onClick on div/span without role"
      img_no_alt: "<img> without alt prop"
      form_no_label: "Input without associated label"

  complexity_indicators:
    high_loc: "Component > 200 lines"
    many_hooks: "Component uses > 5 hooks"
    deep_nesting: "JSX nesting > 5 levels"
    many_props: "Component accepts > 10 props"
    god_component: "high_loc AND many_hooks AND many_props"
```

### Phase 4: Generate Report

```yaml
report:
  summary:
    total_components: N
    pages: N
    layouts: N
    ui_components: N
    hooks: N
    orphaned: N
    without_tests: N
    without_error_boundary: N
    god_components: N

  health_score:
    formula: >
      100 - (orphaned * 2) - (without_tests * 3) - (god_components * 5)
      - (circular_deps * 10) - (any_types * 1)
    max: 100
    thresholds:
      healthy: ">= 80"
      warning: "50-79"
      critical: "< 50"
```

---

## Output Format

```
COMPONENT DISCOVERY
====================
Project: {name}
Components: {total} found ({pages} pages, {layouts} layouts, {ui} UI, {hooks} hooks)
Health Score: {score}/100

COMPONENT MAP
--------------
 #  | Component            | Type   | LOC | Imports | Imported By | Tests | Status
----|----------------------|--------|-----|---------|-------------|-------|--------
 1  | Header               | ui     | 85  | 3       | 4           | Yes   | OK
 2  | ScheduleForm         | ui     | 210 | 8       | 2           | No    | WARN
 3  | GlassInput           | ui     | 45  | 1       | 3           | No    | WARN
 4  | LiquidBackground     | ui     | 120 | 2       | 1           | No    | WARN
 5  | OldTestComponent     | ui     | 30  | 0       | 0           | No    | ORPHAN
 6  | HomePage             | page   | 180 | 12      | 0 (route)   | No    | OK
 7  | useScrollPosition    | hook   | 25  | 0       | 2           | No    | OK

ISSUES ({count})
-----------------
 WARN   #2 ScheduleForm — 210 LOC, 8 imports, 0 tests (god component candidate)
 WARN   #2,#3,#4 — 3 components without tests
 ORPHAN #5 OldTestComponent — exported but never imported (dead code?)
 INFO   No Error Boundary detected in component tree

HUB COMPONENTS (high impact)
-----------------------------
 Header — imported by 4 components (changes affect many files)

DEPENDENCY TREE (simplified)
------------------------------
 HomePage
   ├── Header
   │   ├── GlassInput
   │   └── Logo
   ├── ScheduleForm
   │   ├── GlassInput
   │   └── DatePicker
   └── LiquidBackground

====================
Next steps:
  1. Add tests for untested components (3 files)
  2. Review orphaned component (#5)
  3. Refactor god component (#2 ScheduleForm)

What do you want to do?
```

---

## Integration with Other Tasks

```yaml
feeds_into:
  apex-suggest:
    what: "Component health data enriches proactive suggestions"
    how: "Orphaned, untested, god components become suggestions"

  apex-route-request:
    what: "Routing knows component tree"
    how: "Request mentioning 'Header' auto-identifies file and dependencies"

  apex-scan:
    what: "Enriches project scan with component inventory"
    how: "Component data cached alongside scan context"

  apex-audit:
    what: "Component health score feeds audit report"
    how: "Health score becomes part of project readiness assessment"

  apex-fix:
    what: "Fix knows component dependencies"
    how: "Changing a hub component triggers impact warning"

  smart_defaults:
    what: "Auto-select component for operations"
    how: "If user mentions component name, auto-resolve to file path"
```

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-DISC-COMP-001
    condition: "No React component files found in project"
    action: "BLOCK — not a React project, discovery not applicable"
    blocking: true

  - id: VC-DISC-COMP-002
    condition: "Project has > 500 components"
    action: "WARN — large project, discovery may take a moment"
    blocking: false
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | apex-lead (routing enrichment), apex-suggest (proactive data) |
| Next action | User picks component to fix/test/refactor, or continues to other commands |

---

*Apex Squad — Component Discovery Task v1.0.0*
