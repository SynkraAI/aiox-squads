# Task: apex-design-critique

```yaml
id: apex-design-critique
version: "1.0.0"
title: "Apex Design Critique"
description: >
  Goes beyond scoring — explains WHY a design works or doesn't using formal
  design principles (Gestalt, visual hierarchy, F-pattern, color theory,
  typography rules, spacing rhythm). Educational + actionable.
  Teaches the user while improving the design.
elicit: true
owner: apex-lead
executor: interaction-dsgn
dependencies:
  - tasks/apex-visual-analyze.md
  - tasks/apex-fix.md
outputs:
  - Design critique with principle-backed reasoning
  - Before/after suggestions with rationale
  - Learning points for the user
```

---

## Command

### `*apex-critique {print or component}`

Deep design critique backed by formal principles. Not just "what's wrong" but "WHY it's wrong and how design theory explains it."

---

## How It Works

### Step 1: Analyze Through Design Principles

```yaml
principles_framework:

  gestalt:
    name: "Gestalt Principles"
    checks:
      proximity: "Are related elements grouped together?"
      similarity: "Do similar elements look similar?"
      continuity: "Does the eye flow naturally through the layout?"
      closure: "Are incomplete shapes perceived as complete?"
      figure_ground: "Is the foreground clearly separated from background?"
    application: "Evaluate grouping, spacing, and visual relationships"

  visual_hierarchy:
    name: "Visual Hierarchy"
    checks:
      size: "Are important elements larger?"
      color: "Do colors guide attention correctly?"
      contrast: "Is the primary CTA the highest-contrast element?"
      whitespace: "Does spacing create breathing room around key elements?"
      position: "Are key elements in expected positions (F-pattern, Z-pattern)?"
    application: "Evaluate where the eye goes first, second, third"

  typography_rules:
    name: "Typography"
    checks:
      scale: "Does the type scale follow a ratio (1.25, 1.333, 1.5)?"
      hierarchy: "Are heading levels visually distinct?"
      measure: "Is line length between 45-75 characters?"
      leading: "Is line height 1.4-1.6x for body text?"
      contrast: "Is text/background contrast sufficient?"
      pairing: "Do font pairings create harmony (serif+sans, geometric+humanist)?"
    application: "Evaluate readability and typographic rhythm"

  color_theory:
    name: "Color Theory"
    checks:
      harmony: "Does the palette use a color harmony (complementary, analogous, triadic)?"
      meaning: "Do colors convey correct meaning (red=danger, green=success)?"
      saturation: "Is saturation consistent across the palette?"
      accessibility: "Do all color combinations pass WCAG AA?"
      temperature: "Is color temperature consistent with brand mood?"
    application: "Evaluate palette coherence and emotional impact"

  spacing_rhythm:
    name: "Spacing & Rhythm"
    checks:
      base_unit: "Is spacing based on a consistent unit (4px, 8px)?"
      vertical_rhythm: "Do elements align to a baseline grid?"
      consistency: "Is the same spacing used for similar contexts?"
      density: "Is content density appropriate for the context?"
      breathing: "Do key elements have adequate whitespace?"
    application: "Evaluate spatial harmony and consistency"

  layout_composition:
    name: "Layout & Composition"
    checks:
      grid: "Is there an underlying grid structure?"
      alignment: "Are elements aligned to common edges?"
      balance: "Is the layout visually balanced (symmetric or asymmetric)?"
      rule_of_thirds: "Are focal points near intersection points?"
      negative_space: "Is negative space used intentionally?"
    application: "Evaluate structural integrity and visual balance"
```

### Step 2: Generate Critique

```yaml
critique_format: |
  ## Design Critique

  ### O que funciona (e por que)

  **{strength_1}**
  Principio: {principle_name} — {principle_explanation}
  > {specific observation about what works and why it works from a design theory perspective}

  **{strength_2}**
  Principio: {principle_name} — {principle_explanation}
  > {specific observation}

  ### O que pode melhorar (e por que)

  **{issue_1}**
  Principio violado: {principle_name}
  Problema: {what's wrong}
  Teoria: {why design theory says this doesn't work}
  Sugestao: {specific fix with rationale}

  **{issue_2}**
  Principio violado: {principle_name}
  Problema: {what's wrong}
  Teoria: {why this matters}
  Sugestao: {specific fix}

  ### Resumo dos Principios Aplicados

  | Principio | Score | Nota |
  |-----------|-------|------|
  | Gestalt | {score}/10 | {note} |
  | Hierarquia Visual | {score}/10 | {note} |
  | Tipografia | {score}/10 | {note} |
  | Cor | {score}/10 | {note} |
  | Spacing/Ritmo | {score}/10 | {note} |
  | Composicao | {score}/10 | {note} |

  ### Aprendizado
  > {1-2 key takeaways the user can apply to future designs}
```

### Step 3: Options

```yaml
options:
  1_apply:
    label: "Aplicar melhorias sugeridas"
    action: "Convert suggestions to fix list, route to *apex-quick"

  2_deep_dive:
    label: "Aprofundar em um principio especifico"
    action: "User picks principle, expand with more examples"

  3_compare:
    label: "Comparar com referencia que segue esses principios"
    action: "Route to *apex-compare with curated reference"

  4_report:
    label: "So quero a critica"
    action: "End"
```

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-DC-001
    condition: "Critique delivered without citing design principles"
    action: "VETO — Every critique point must reference a formal principle."
    available_check: "manual"
    on_unavailable: MANUAL_CHECK
```

---

*Apex Squad — Design Critique Task v1.0.0*
