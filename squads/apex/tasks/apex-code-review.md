# Task: apex-code-review

```yaml
id: apex-code-review
version: "1.0.0"
title: "Apex Frontend Code Review"
description: >
  Structured code review for frontend implementations. Audits React patterns,
  hook usage, component architecture, state management, error handling, and
  code quality. Multi-agent: @react-eng reviews logic, @frontend-arch reviews
  architecture, @perf-eng reviews performance patterns.
elicit: true
owner: apex-lead
executor: apex-lead
dependencies:
  - tasks/apex-fix.md
  - tasks/apex-quick.md
  - checklists/component-quality-checklist.md
outputs:
  - Code review report with categorized findings
  - Severity-ranked fix list
  - Actionable improvement plan
```

---

## Command

### `*apex-review {file|component|branch}`

Reviews frontend code for quality, patterns, and best practices.

---

## How It Works

### Step 1: Scope Detection

```yaml
scope:
  file: "Review single file"
  component: "Review component + its dependencies"
  branch: "Review all changed files in current branch vs main"
  auto: "If no arg, review files changed since last commit"
```

### Step 2: Multi-Agent Review

```yaml
review_dimensions:

  react_patterns:
    agent: "@react-eng"
    checks:
      - Hook rules (no conditional hooks, deps arrays correct)
      - Custom hooks extraction (logic reuse opportunities)
      - Component composition (prop drilling vs context vs composition)
      - Render optimization (useMemo/useCallback usage, not overuse)
      - Error boundaries presence for async/fallible components
      - Key prop usage in lists (no index as key for dynamic lists)
      - Controlled vs uncontrolled inputs consistency
      - Effect cleanup (subscriptions, timers, listeners)
      - Server/client component boundary correctness (if Next.js)
    severity_map:
      critical: [missing_error_boundary, hook_rules_violation, memory_leak]
      high: [prop_drilling_deep, missing_cleanup, wrong_boundary]
      medium: [unnecessary_memo, missing_key, inconsistent_patterns]
      low: [naming_convention, import_order]

  architecture:
    agent: "@frontend-arch"
    checks:
      - File organization (colocation, barrel exports)
      - Dependency direction (no circular imports)
      - Abstraction level (god components, too many responsibilities)
      - API layer separation (data fetching not in UI components)
      - Type safety (proper TypeScript usage, no `any` abuse)
      - Module boundaries (shared vs feature-specific)
    severity_map:
      critical: [circular_dependency, type_any_abuse]
      high: [god_component, mixed_concerns, wrong_layer]
      medium: [barrel_export_missing, naming_inconsistency]
      low: [file_organization]

  performance_patterns:
    agent: "@perf-eng"
    checks:
      - Re-render triggers (state updates causing unnecessary renders)
      - Bundle impact (heavy imports, missing dynamic import)
      - Image handling (next/image, lazy loading, sizing)
      - List virtualization (large lists without windowing)
      - Memoization (correct usage, not premature)
    severity_map:
      critical: [infinite_rerender, huge_bundle_import]
      high: [missing_lazy_load, unvirtualized_list]
      medium: [unnecessary_rerender, missing_dynamic_import]
      low: [premature_optimization]

  accessibility_patterns:
    agent: "@a11y-eng"
    checks:
      - Semantic HTML usage (div soup vs proper elements)
      - ARIA attributes correctness
      - Form labels and error association
      - Focus management in dynamic content
      - Keyboard event handlers (onClick without onKeyDown)
    severity_map:
      critical: [no_label, keyboard_trap]
      high: [div_button, missing_aria, no_focus_management]
      medium: [missing_alt, wrong_role]
      low: [redundant_aria]
```

### Step 3: Generate Report

```yaml
report_format: |
  ## Code Review — {scope}

  **Arquivos revisados:** {file_count}
  **Agentes:** {agents_used}

  ### Findings por Severidade

  | # | Severidade | Categoria | Arquivo | Linha | Finding |
  |---|-----------|-----------|---------|-------|---------|
  | 1 | CRITICAL | {cat} | {file}:{line} | {description} |
  | 2 | HIGH | {cat} | {file}:{line} | {description} |
  | ... | ... | ... | ... | ... | ... |

  ### Resumo

  | Severidade | Count |
  |-----------|-------|
  | CRITICAL | {n} |
  | HIGH | {n} |
  | MEDIUM | {n} |
  | LOW | {n} |

  ### Patterns Positivos (o que esta bom)
  - {positive_1}
  - {positive_2}
```

### Step 4: Present Options

```yaml
options:
  1_fix_critical:
    label: "Corrigir CRITICAL + HIGH ({count} issues)"
    action: "Route to *apex-quick with fix list"

  2_fix_all:
    label: "Corrigir tudo ({total} issues)"
    action: "Route to *apex-go with full fix plan"

  3_fix_one:
    label: "Corrigir issue #{n} especifica"
    action: "Route to *apex-fix for single issue"

  4_report_only:
    label: "So quero o relatorio"
    action: "End — report saved"
```

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-CR-001
    condition: "Code review skipped before ship"
    action: "WARN — Code review recommended before shipping."
    available_check: "manual"
    on_unavailable: MANUAL_CHECK

  - id: VC-CR-002
    condition: "CRITICAL findings present and user wants to ship"
    action: "VETO — CRITICAL code issues must be resolved before ship."
    available_check: "manual"
    on_unavailable: BLOCK
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | *apex-fix or *apex-quick based on user choice |
| Artifact | Code review report + prioritized fix list |
| Next action | Fix selected issues |

---

*Apex Squad — Code Review Task v1.0.0*
