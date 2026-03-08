# Task: apex-consistency-audit

```yaml
id: apex-consistency-audit
version: "1.0.0"
title: "Apex Cross-Page Consistency Audit"
description: >
  Receives multiple screenshots (3+) from different pages/screens of the same app
  and audits visual consistency across them. Detects inconsistencies in tokens,
  spacing, typography, colors, component usage, and interaction patterns.
  Produces a consistency score and actionable fix plan.
elicit: true
owner: apex-lead
executor: apex-lead
dependencies:
  - tasks/apex-visual-analyze.md
  - tasks/apex-fix.md
  - tasks/apex-quick.md
  - tasks/apex-discover-design.md
outputs:
  - Cross-page consistency report with scores
  - Inconsistency inventory with severity
  - Standardization plan
```

---

## Command

### `*apex-consistency`

User sends 3+ screenshots from different pages/screens of the same app.

---

## Input

```yaml
input:
  minimum: 3  # At least 3 screenshots for meaningful consistency audit
  maximum: 10  # Practical limit per analysis

  per_image:
    required:
      - The image itself
    optional:
      - Page/screen name or route
      - Device/viewport (mobile, desktop, tablet)

  auto_detect:
    - Page type (home, listing, detail, form, dashboard, settings)
    - Platform (web, mobile, desktop)
    - Theme (light, dark)
```

---

## How It Works

### Step 1: Catalog All Pages

```yaml
catalog: |
  For each screenshot:
    1. Identify page type and label
    2. Extract visual tokens used:
       - Colors (palette, backgrounds, text, borders)
       - Typography (fonts, sizes, weights, line heights)
       - Spacing (padding, margin, gaps — estimate from pixels)
       - Radius (border-radius patterns)
       - Shadows (elevation levels)
       - Icons (style, size, consistency)
    3. Identify shared components (header, footer, nav, buttons, cards, forms)
    4. Note interaction patterns visible (CTAs, navigation, feedback)
```

### Step 2: Cross-Page Consistency Analysis

```yaml
consistency_checks:

  color_consistency:
    agent: "@design-sys-eng"
    checks:
      - Same semantic color used consistently (primary, secondary, accent)
      - Background colors match across pages
      - Text colors consistent (heading, body, muted)
      - Status colors uniform (error, success, warning, info)
      - No rogue colors (colors appearing on only 1 page)
    severity_if_inconsistent: HIGH

  typography_consistency:
    agent: "@css-eng"
    checks:
      - Same font family across all pages
      - Heading sizes consistent (H1 on page A == H1 on page B)
      - Body text same size and line height
      - Font weight usage consistent (when is bold used?)
      - No rogue fonts (fonts appearing on only 1 page)
    severity_if_inconsistent: HIGH

  spacing_consistency:
    agent: "@css-eng"
    checks:
      - Section padding consistent
      - Component internal spacing matches
      - Gap between elements follows same scale
      - Page margins consistent
    severity_if_inconsistent: MEDIUM

  component_consistency:
    agent: "@design-sys-eng"
    checks:
      - Buttons look the same across pages (shape, size, style)
      - Cards use same structure (padding, radius, shadow)
      - Forms have same input styles
      - Header/footer identical
      - Icons from same family and size
    severity_if_inconsistent: HIGH

  interaction_consistency:
    agent: "@interaction-dsgn"
    checks:
      - CTA placement follows same pattern
      - Navigation patterns uniform
      - Feedback patterns consistent (toasts, modals, inline)
      - Empty/loading/error states follow same design
    severity_if_inconsistent: MEDIUM

  motion_consistency:
    agent: "@motion-eng"
    checks:
      - Animation style uniform (spring vs. bezier)
      - Entrance/exit patterns match
      - Hover/press effects consistent
    severity_if_inconsistent: LOW

  accessibility_consistency:
    agent: "@a11y-eng"
    checks:
      - Contrast ratios consistent across pages
      - Touch targets same minimum size
      - Focus indicators visible on all pages
    severity_if_inconsistent: HIGH
```

### Step 3: Generate Consistency Report

```yaml
report_format: |
  ## Auditoria de Consistencia — {app_name}

  **Paginas analisadas:** {count}
  {list of page labels}

  ### Consistency Score

  | Dimensao | Score | Inconsistencias | Severidade |
  |----------|-------|-----------------|------------|
  | Cores | {score}/100 | {count} | {HIGH|MEDIUM|LOW} |
  | Tipografia | {score}/100 | {count} | {HIGH|MEDIUM|LOW} |
  | Spacing | {score}/100 | {count} | {HIGH|MEDIUM|LOW} |
  | Componentes | {score}/100 | {count} | {HIGH|MEDIUM|LOW} |
  | Interacao | {score}/100 | {count} | {HIGH|MEDIUM|LOW} |
  | Motion | {score}/100 | {count} | {HIGH|MEDIUM|LOW} |
  | Acessibilidade | {score}/100 | {count} | {HIGH|MEDIUM|LOW} |
  | **GERAL** | **{avg}/100** | **{total}** | — |

  ### Inconsistencias Detectadas (ordenadas por severidade)

  | # | Dimensao | Inconsistencia | Paginas afetadas | Severidade |
  |---|----------|---------------|------------------|------------|
  | 1 | {dim} | {description} | {pages} | HIGH |
  | 2 | {dim} | {description} | {pages} | HIGH |
  | ... | ... | ... | ... | ... |

  ### Tokens que DEVEM ser padronizados

  | Token | Valor recomendado | Usado incorretamente em |
  |-------|-------------------|------------------------|
  | {token} | {value} | {pages} |

  ### Componentes com variacao visual

  | Componente | Variacao | Paginas |
  |------------|----------|---------|
  | {component} | {what differs} | {pages} |
```

### Step 4: Present Options

```yaml
options:
  1_fix_all:
    label: "PADRONIZAR TUDO — Corrigir todas as inconsistencias"
    action: "Generate comprehensive fix plan, route to *apex-go"
    scope: "Full pipeline"

  2_fix_critical:
    label: "SO CRITICAS — Corrigir apenas HIGH severity"
    action: "Filter HIGH items, route to *apex-quick"
    scope: "Quick pipeline"

  3_design_system:
    label: "CRIAR DESIGN SYSTEM — Extrair tokens e padronizar"
    action: "Run *discover-design, then generate token standardization plan"
    scope: "Design system creation"

  4_page_by_page:
    label: "PAGINA POR PAGINA — Alinhar uma pagina de cada vez"
    action: "User picks reference page, align others to it"
    scope: "Incremental"

  5_analyze_one:
    label: "APROFUNDAR — Analisar uma pagina especifica"
    action: "Route to *apex-visual-analyze for single page deep dive"

  6_done:
    label: "DONE — So quero o relatorio"
    action: "End chain, report saved"
```

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-CA-001
    condition: "Consistency audit attempted with fewer than 3 screenshots"
    action: "VETO — Minimum 3 pages for meaningful consistency analysis. Use *apex-compare for 2."
    available_check: "manual"
    on_unavailable: BLOCK

  - id: VC-CA-002
    condition: "Standardization executed without user choosing reference page/tokens"
    action: "VETO — User must confirm which page is the 'source of truth' before standardizing."
    available_check: "manual"
    on_unavailable: BLOCK
```

---

## Quality Gate

```yaml
gate:
  id: QG-apex-consistency-audit
  blocker: true
  criteria:
    - "Minimum 3 pages cataloged"
    - "All 7 consistency dimensions checked"
    - "Inconsistencies listed with severity"
    - "Token standardization recommendations provided"
    - "Options presented after report"
  on_fail: "BLOCK — complete audit before options"
  on_pass: "Route to selected action"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | Selected pipeline based on user choice |
| Artifact | Consistency report + user decision |
| Next action | Standardize (full, critical-only, or page-by-page) |

---

*Apex Squad — Consistency Audit Task v1.0.0*
