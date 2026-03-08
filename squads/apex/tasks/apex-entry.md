# Task: apex-entry

```yaml
id: apex-entry
version: "1.0.0"
title: "Apex Single Entry Point"
description: >
  Universal entry point for the Apex squad. User describes what they want in
  natural language, and this task auto-selects the right pipeline, agents, and
  execution mode. No need to know commands or agent names.
elicit: true
owner: apex-lead
executor: apex-lead
dependencies:
  - tasks/apex-scan.md
  - tasks/apex-route-request.md
  - tasks/apex-fix.md
  - tasks/apex-quick.md
  - tasks/apex-pipeline-executor.md
  - tasks/apex-suggest.md
outputs:
  - Automatic pipeline selection and execution
  - Post-operation suggestions
```

---

## Command

### `@apex {natural language request}`

The user just talks naturally. Apex figures out everything else.

---

## How It Works

### Step 1: Scan (if not cached)

```
IF no project context cached:
  Run apex-scan.md (silent mode)
  Store context
```

### Step 2: Classify Request

Analyze the user's natural language to determine:

```yaml
classification:
  intent:
    - fix: "User wants to fix something broken"
    - improve: "User wants to enhance something existing"
    - create: "User wants to build something new"
    - redesign: "User wants to change the look/feel"
    - audit: "User wants to check quality"
    - analyze: "User sends a screenshot/print for visual analysis"
    - question: "User is asking about the codebase"

  scope:
    - micro: "1 file, 1 property change"
    - small: "1-3 files, single domain"
    - medium: "3-10 files, 2-3 domains"
    - large: "10+ files, new feature/component"
    - cross_platform: "Affects web + mobile"

  input_type:
    - text: "User describes in natural language (default)"
    - visual: "User sends screenshot/print/image"
    - multi_visual: "User sends 2+ screenshots"

  visual_input_detection:
    triggers:
      - "User attaches an image (png, jpg, webp, gif)"
      - "User says: analisa esse print/screenshot/tela/pagina/design"
      - "User says: olha esse app/site, quero assim, faz igual"
      - "User says: compara com, lado a lado, antes e depois"
    auto_classify:
      - if: "1 image attached"
        intent: analyze
        pipeline: "*apex-analyze"
      - if: "2 images attached"
        intent: analyze
        pipeline: "*apex-compare"
      - if: "3+ images attached"
        intent: analyze
        pipeline: "*apex-consistency"

  domains:
    detect_from_keywords:
      css: [layout, spacing, responsive, mobile, breakpoint, grid, flexbox, padding, margin, color, background, border, shadow, blur, font, text, align, position, overflow, z-index, tailwind]
      react: [component, state, hook, prop, render, conditional, loading, error, form, input, button, modal, drawer, list, card]
      motion: [animation, spring, transition, entrance, exit, hover, bounce, smooth, stagger, parallax, scroll]
      a11y: [accessibility, contrast, screen reader, keyboard, focus, aria, tab, wcag, semantic]
      perf: [performance, slow, loading, bundle, lazy, optimize, cache, re-render, lighthouse]
      ux: [flow, experience, redesign, layout, navigation, interaction, feedback, confirmation]
      visual_qa: [looks wrong, pixel, regression, different, broken, screenshot]
      visual_analyze: [print, screenshot, analisa, olha esse, quero assim, faz igual, compara, referencia, inspiracao]
```

### Step 3: Select Pipeline

```yaml
pipeline_selection:
  # Intent + Scope → Pipeline
  rules:
    - if: "intent == fix AND scope in [micro, small]"
      pipeline: "*apex-fix"
      reason: "Small fix, single agent"

    - if: "intent == fix AND scope == medium"
      pipeline: "*apex-quick"
      reason: "Multi-file fix needs coordinated approach"

    - if: "intent == improve AND scope in [micro, small]"
      pipeline: "*apex-fix"
      reason: "Small improvement, single agent"

    - if: "intent == improve AND scope >= medium"
      pipeline: "*apex-quick"
      reason: "Enhancement touching multiple domains"

    - if: "intent == create AND scope in [micro, small]"
      pipeline: "*apex-quick"
      reason: "New component needs specify phase"

    - if: "intent == create AND scope >= medium"
      pipeline: "*apex-go"
      reason: "New feature needs full pipeline"

    - if: "intent == redesign"
      pipeline: "*apex-quick"
      reason: "Visual changes need scope confirmation"

    - if: "intent == audit"
      pipeline: "*apex-audit"
      reason: "Diagnostic only"

    - if: "intent == analyze AND input_type == visual"
      pipeline: "*apex-analyze"
      reason: "Visual input detected — deep multi-dimensional analysis"

    - if: "intent == analyze AND multi_visual == 2"
      pipeline: "*apex-compare"
      reason: "Two images — side-by-side comparison"

    - if: "intent == analyze AND multi_visual >= 3"
      pipeline: "*apex-consistency"
      reason: "Multiple pages — cross-page consistency audit"

    - if: "intent == question"
      pipeline: null
      reason: "Answer directly, no pipeline needed"

    - if: "scope == cross_platform"
      pipeline: "*apex-go"
      reason: "Cross-platform always needs full pipeline"
```

### Step 4: Present Plan (brief)

Show a concise plan before executing:

```
@apex understood.

Pipeline: *apex-fix
Agent: @css-eng (Josh)
Action: Fix header overlap on mobile
Files: likely src/components/Header.tsx

Proceed? (yes / adjust / different approach)
```

For larger scopes:

```
@apex understood.

Pipeline: *apex-quick (3 phases)
Agents: @react-eng + @css-eng + @motion-eng
Action: Add animated stats card to dashboard
Estimated files: 3-5

Proceed? (yes / adjust / use *apex-go instead)
```

### Step 5: Execute

On user confirmation, delegate to the selected pipeline task.

**IMPORTANT:** All delegations MUST follow the **Handoff Protocol** (`apex-handoff-protocol.md`):
- Emil announces WHO he is delegating to and WHY
- Specialist introduces themselves in 1 line
- Specialist completes and suggests next agent + options
- See `apex-handoff-protocol.md` for exact formats

```
IF pipeline == "*apex-fix":
  Execute apex-fix.md with description (handoff protocol active)
ELIF pipeline == "*apex-quick":
  Execute apex-quick.md with description (handoff protocol active)
ELIF pipeline == "*apex-go":
  Execute apex-pipeline-executor.md in autonomous mode
ELIF pipeline == "*apex-audit":
  Execute apex-audit.md
ELIF pipeline == null:
  Answer the question directly using project context
```

### Step 6: Post-Operation Suggestions

After pipeline completes, run apex-suggest.md (automatic mode):

```
1. Scan modified files for issues
2. If suggestions found, append to completion report
3. User decides whether to apply any
```

---

## Natural Language Examples

### Simple fixes (auto-routes to *apex-fix)

```
User: "o header ta sobrepondo no mobile"
Apex: Pipeline: *apex-fix | Agent: @css-eng | Fix responsive overlap
      Proceed?

User: "o botao de agendar nao tem hover"
Apex: Pipeline: *apex-fix | Agent: @css-eng | Add hover state to CTA button
      Proceed?

User: "o formulario nao mostra loading"
Apex: Pipeline: *apex-fix | Agent: @react-eng | Add loading state to form
      Proceed?
```

### Medium changes (auto-routes to *apex-quick)

```
User: "quero um card de estatisticas com animacao de entrada"
Apex: Pipeline: *apex-quick | Agents: @react-eng + @css-eng + @motion-eng
      Action: New stats card component with spring entrance
      Proceed?

User: "redesenha a secao de servicos pra ficar melhor no celular"
Apex: Pipeline: *apex-quick | Agents: @css-eng + @interaction-dsgn
      Action: Responsive redesign of services section
      Proceed?
```

### Large features (auto-routes to *apex-go)

```
User: "adiciona um dashboard de pacientes completo com graficos e filtros"
Apex: Pipeline: *apex-go (full 7 phases) | Multiple agents
      Action: Full patient dashboard feature
      This is a large feature — full pipeline recommended for quality.
      Proceed?
```

### Questions (no pipeline)

```
User: "quais componentes usam framer motion?"
Apex: [Scans codebase, lists components using motion]
      No pipeline needed — this is an informational query.

User: "como ta a performance do site?"
Apex: [Provides performance analysis based on code patterns]
      Want me to run *apex-audit for a full diagnostic?
```

---

## Override Rules

```yaml
overrides:
  - User can always specify a pipeline explicitly:
    "*apex-fix ..." overrides auto-selection
    "*apex-quick ..." overrides auto-selection
    "*apex-go ..." overrides auto-selection

  - User can request a specific agent:
    "@css-eng fix the margin" routes directly to css-eng

  - User can say "just do it" to skip the plan confirmation:
    Apex proceeds without the Step 4 confirmation

  - User can say "use full pipeline" to force *apex-go:
    Regardless of scope classification
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | Selected pipeline task |
| Next action | Pipeline executes per its own protocol |

---

*Apex Squad — Single Entry Point Task v1.0.0*
