# Task: apex-visual-analyze

```yaml
id: apex-visual-analyze
version: "1.0.0"
title: "Apex Visual Analyze"
description: >
  Receives a screenshot/print (icon, button, component, full page, or external app)
  and performs deep multi-dimensional analysis. Produces a structured report with
  scores per dimension and presents actionable options: keep, improve, replicate,
  transform, or compare.
elicit: true
owner: apex-lead
executor: apex-lead
dependencies:
  - tasks/apex-scan.md
  - tasks/apex-route-request.md
  - tasks/apex-fix.md
  - tasks/apex-quick.md
  - tasks/apex-transform.md
  - tasks/apex-compare.md
  - data/design-presets.yaml
  - data/veto-conditions.yaml
outputs:
  - Visual analysis report with dimensional scores
  - Actionable options for user decision
  - Pipeline routing based on user choice
```

---

## Command

### `@apex {print/screenshot}` or `*apex-analyze`

User sends an image (screenshot, print, photo of UI) with optional description.
Apex detects visual input and routes here automatically.

---

## Input Detection

```yaml
visual_input_detection:
  triggers:
    - User attaches an image file (png, jpg, webp, gif, svg)
    - User says "analisa esse print/screenshot/tela/pagina/design"
    - User pastes a screenshot in the conversation
    - User references an image path

  classify_source:
    internal: "Screenshot is from the current project"
    external: "Screenshot is from another app/site (reference/inspiration)"
    mixed: "Multiple screenshots, some internal some external"

  auto_detect_source:
    - if: "Image matches known project routes/components"
      source: internal
    - if: "User says 'quero assim', 'faz igual', 'olha esse app'"
      source: external
    - if: "Unclear"
      ask: "Esse print e do seu projeto atual ou de uma referencia externa?"
```

---

## How It Works

### Step 1: Identify What Was Sent

```yaml
identification:
  scope:
    - micro: "Icon, button, single element"
    - component: "Card, form, modal, header, footer"
    - section: "Hero, services section, sidebar"
    - page: "Full page/screen"
    - flow: "Multiple screens showing a user flow"

  detect:
    - Element boundaries and hierarchy
    - Platform (web, mobile, desktop)
    - State (default, hover, active, error, loading, empty)
    - Light/dark mode
    - Approximate breakpoint/viewport
```

### Step 2: Deep Multi-Dimensional Analysis

Run analysis across ALL dimensions. Each agent contributes their expertise:

```yaml
analysis_dimensions:

  layout:
    agent: "@css-eng"
    checks:
      - Grid/flexbox structure and alignment
      - Spacing consistency (follows 4px/8px scale?)
      - Visual hierarchy and reading flow
      - Responsive potential (will this break on smaller screens?)
      - Content density (too crowded? too sparse?)
    score: 0-100

  typography:
    agent: "@css-eng"
    checks:
      - Font choices and pairing quality
      - Size scale consistency
      - Line height and letter spacing
      - Readability and contrast
      - Hierarchy (H1 > H2 > body clear?)
    score: 0-100

  color:
    agent: "@design-sys-eng"
    checks:
      - Palette harmony and consistency
      - Brand alignment
      - Contrast ratios (WCAG AA: 4.5:1 text, 3:1 large)
      - Color meaning consistency (red=error, green=success)
      - Dark mode readiness
    score: 0-100

  composition:
    agent: "@interaction-dsgn"
    checks:
      - Visual balance and weight distribution
      - Focal point clarity (where does eye go first?)
      - White space usage
      - Component grouping (Gestalt principles)
      - Call-to-action prominence
    score: 0-100

  interaction_design:
    agent: "@interaction-dsgn"
    checks:
      - Affordance clarity (does it look clickable/tappable?)
      - State indication (active, disabled, loading visible?)
      - Feedback patterns (what happens on click?)
      - Navigation clarity
      - Error prevention patterns
    score: 0-100

  motion_potential:
    agent: "@motion-eng"
    checks:
      - Entrance/exit animation opportunities
      - Micro-interaction candidates (hover, press, toggle)
      - Scroll-driven animation potential
      - Spring physics applicability
      - Reduced motion considerations
    score: 0-100

  accessibility:
    agent: "@a11y-eng"
    checks:
      - Color contrast (WCAG 2.2 AA)
      - Touch target sizes (>= 44x44px mobile, >= 24x24px web)
      - Text readability at various sizes
      - Focus indicator visibility
      - Screen reader friendliness (semantic structure)
    score: 0-100

  performance_impact:
    agent: "@perf-eng"
    checks:
      - Image optimization opportunities
      - Animation performance risk (will it jank?)
      - Render complexity (too many layers/shadows/blurs?)
      - Lazy loading candidates
      - Bundle impact estimate
    score: 0-100
```

### Step 3: Generate Report

```yaml
report_format: |
  ## Analise Visual — {scope_type}

  **Fonte:** {internal|external}
  **Escopo:** {micro|component|section|page|flow}
  **Plataforma detectada:** {web|mobile|desktop}

  ### Scores por Dimensao

  | Dimensao | Score | Highlights |
  |----------|-------|------------|
  | Layout | {score}/100 | {1-line summary} |
  | Tipografia | {score}/100 | {1-line summary} |
  | Cores | {score}/100 | {1-line summary} |
  | Composicao | {score}/100 | {1-line summary} |
  | Interacao | {score}/100 | {1-line summary} |
  | Motion | {score}/100 | {1-line summary} |
  | Acessibilidade | {score}/100 | {1-line summary} |
  | Performance | {score}/100 | {1-line summary} |
  | **GERAL** | **{avg}/100** | — |

  ### Top 3 Pontos Fortes
  1. {strength_1}
  2. {strength_2}
  3. {strength_3}

  ### Top 3 Oportunidades de Melhoria
  1. {improvement_1} — Severidade: {HIGH|MEDIUM|LOW}
  2. {improvement_2} — Severidade: {HIGH|MEDIUM|LOW}
  3. {improvement_3} — Severidade: {HIGH|MEDIUM|LOW}
```

### Step 4: Present Options

After the report, ALWAYS present actionable options:

```yaml
options:
  source_internal:
    description: "Print e do projeto atual"
    choices:
      1_keep:
        label: "MANTER — Esta bom, sem mudancas"
        action: "End analysis. Log report for reference."
        next_chain: "after_analyze.keep"

      2_improve:
        label: "APERFEICOAR — Melhorar o que tem"
        action: "Generate specific fix list from improvements, route to *apex-fix or *apex-quick"
        next_chain: "after_analyze.improve"
        sub_options:
          - "Corrigir apenas issues HIGH"
          - "Corrigir HIGH + MEDIUM"
          - "Corrigir tudo (incluindo LOW)"

      3_transform:
        label: "TRANSFORMAR — Aplicar um estilo diferente"
        action: "Show *apex-inspire catalog, then *apex-transform"
        next_chain: "after_analyze.transform"

      4_compare:
        label: "COMPARAR — Colocar lado a lado com outra referencia"
        action: "Ask for second image, run *apex-compare"
        next_chain: "after_analyze.compare"

  source_external:
    description: "Print e de referencia externa (outro app/site)"
    choices:
      1_replicate:
        label: "REPLICAR — Recriar esse design no meu projeto"
        action: "Extract design tokens from image, create implementation spec, route to *apex-quick or *apex-go"
        next_chain: "after_analyze.replicate"
        sub_steps:
          - "Extrair tokens visuais (cores, fontes, spacing, radius, shadows)"
          - "Mapear para design system existente do projeto"
          - "Gerar spec de implementacao"
          - "Apresentar plano antes de executar"

      2_inspire:
        label: "INSPIRAR — Usar como base mas adaptar ao meu estilo"
        action: "Identify closest Apex preset, suggest *apex-transform with overrides"
        next_chain: "after_analyze.inspire"

      3_compare:
        label: "COMPARAR — Comparar com minha implementacao atual"
        action: "Ask which page/component to compare, run *apex-compare"
        next_chain: "after_analyze.compare"

      4_elements:
        label: "ELEMENTOS — Extrair apenas elementos especificos"
        action: "User picks which elements to extract (buttons, cards, colors, etc.)"
        next_chain: "after_analyze.elements"
        sub_options:
          - "Extrair paleta de cores"
          - "Extrair tipografia"
          - "Extrair layout/grid"
          - "Extrair componente especifico"

  always_available:
    5_another:
      label: "ANALISAR OUTRO — Enviar outro print"
      action: "Reset and wait for new image"
    6_done:
      label: "DONE — Encerrar analise"
      action: "End chain"
```

### Step 5: Execute User Choice

```yaml
execution:
  keep:
    action: "Log analysis report to .aios/apex-context/visual-history.yaml"
    show: "Analise registrada. Pronto pra outra coisa?"

  improve:
    action: |
      1. Convert improvements to actionable fix list
      2. Classify scope (micro/small/medium)
      3. Route to *apex-fix (1-3 items) or *apex-quick (4+ items)
      4. Execute fixes
      5. After: suggest comparing before/after

  replicate:
    action: |
      1. Extract complete design language from screenshot
      2. Map to current project tokens (identify gaps)
      3. Generate implementation plan
      4. Present plan to user for approval
      5. Route to *apex-quick (component) or *apex-go (page)

  transform:
    action: |
      1. Run *apex-inspire to show catalog
      2. Suggest closest matching preset
      3. User picks preset
      4. Run *apex-transform --style {id}

  inspire:
    action: |
      1. Identify closest Apex preset to reference image
      2. Show: "Preset mais proximo: {preset_name} ({match_score}%)"
      3. Suggest *apex-transform with custom overrides
      4. Extract specific tokens from reference to use as overrides

  compare:
    action: "Route to apex-compare.md with both images"

  elements:
    action: |
      1. User selects which elements to extract
      2. Extract selected tokens from image
      3. Present as ready-to-use CSS variables / Tailwind config
      4. User decides: apply to project or save as reference
```

---

## Multi-Image Support

```yaml
multi_image:
  detection: "User sends 2+ images in same message"
  behavior:
    - if: "2 images"
      action: "Auto-route to *apex-compare (side by side)"
    - if: "3+ images"
      action: "Auto-route to *apex-consistency-audit (cross-page)"
    - if: "1 image + description mentioning another page"
      action: "Ask for second image, then *apex-compare"
```

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-VA-001
    condition: "Analysis produced without scores for ALL 8 dimensions"
    action: "VETO — All dimensions must be scored. No partial analysis."
    available_check: "manual"
    on_unavailable: MANUAL_CHECK

  - id: VC-VA-002
    condition: "Options not presented after analysis"
    action: "VETO — User must always receive actionable options."
    available_check: "manual"
    on_unavailable: MANUAL_CHECK

  - id: VC-VA-003
    condition: "Replicate/improve action executed without user confirmation"
    action: "VETO — NEVER auto-execute. Always present plan and wait."
    available_check: "manual"
    on_unavailable: BLOCK
```

---

## Quality Gate

```yaml
gate:
  id: QG-apex-visual-analyze
  blocker: true
  criteria:
    - "All 8 dimensions scored"
    - "Top 3 strengths identified"
    - "Top 3 improvements identified with severity"
    - "Options presented matching source type (internal/external)"
    - "User choice recorded before any execution"
  on_fail: "BLOCK — complete analysis before presenting options"
  on_pass: "Route to selected pipeline"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | Selected pipeline based on user choice |
| Artifact | Analysis report + user decision |
| Next action | Execute chosen option (improve/replicate/transform/compare) |

---

*Apex Squad — Visual Analyze Task v1.0.0*
