# Task: apex-discover-design

```yaml
id: apex-discover-design
version: "1.0.0"
title: "Design System Discovery"
description: >
  Scans the project codebase to map the REAL design system in use:
  CSS variables, Tailwind config, color palette, spacing scale,
  typography, breakpoints, and violations (hardcoded values).
  Transforms "what's your design system?" into "I already scanned
  your code — here's what you're actually using."
elicit: false
owner: apex-lead
executor: design-sys-eng
dependencies:
  - tasks/apex-scan.md
outputs:
  - Complete design token inventory (colors, spacing, typography, breakpoints)
  - Tailwind config extensions mapped
  - Hardcoded value violations (hex, px, font-size outside tokens)
  - Consistency analysis (most-used vs outliers)
  - Design language classification
```

---

## Command

### `*discover-design`

Scans the project and maps the real design system. Runs as part of `*apex-audit` or independently.

---

## Discovery Phases

### Phase 1: Scan Token Sources

```yaml
token_sources:
  css_variables:
    scan:
      - "src/**/*.css"
      - "app/**/*.css"
      - "styles/**/*.css"
    extract:
      - "All :root { --var: value } declarations"
      - "All [data-theme] or .dark { --var: value } declarations"
    classify:
      color: "--color-*, --bg-*, --text-*, --border-*"
      spacing: "--spacing-*, --gap-*, --padding-*, --margin-*"
      typography: "--font-*, --text-*, --leading-*, --tracking-*"
      radius: "--radius-*, --rounded-*"
      shadow: "--shadow-*"
      animation: "--duration-*, --ease-*, --spring-*"
      z_index: "--z-*"

  tailwind_config:
    scan:
      - "tailwind.config.js"
      - "tailwind.config.ts"
      - "tailwind.config.mjs"
    extract:
      - "theme.extend.colors"
      - "theme.extend.spacing"
      - "theme.extend.fontSize"
      - "theme.extend.fontFamily"
      - "theme.extend.borderRadius"
      - "theme.extend.screens (breakpoints)"
      - "theme.extend.animation"
      - "theme.extend.keyframes"
      - "plugins"

  css_in_js:
    scan:
      - "src/**/theme.ts"
      - "src/**/tokens.ts"
      - "src/**/design-tokens.*"
    extract: "Exported theme/token objects"

  design_language:
    detect:
      glass_morphism:
        signals: ["backdrop-blur", "backdrop-filter", "bg-opacity", "glass", "frosted"]
        confidence: "2+ signals = high"
      material:
        signals: ["elevation", "shadow-md", "ripple", "surface", "outlined"]
        confidence: "2+ signals = high"
      flat:
        signals: ["no shadows", "solid backgrounds", "sharp corners"]
        confidence: "absence of glass/material signals"
      neumorphism:
        signals: ["inset shadow", "soft shadow", "emboss", "deboss"]
        confidence: "2+ signals = high"
      custom:
        signals: "none of above match clearly"
        action: "Report as custom, list dominant patterns"
```

### Phase 2: Scan Usage

```yaml
usage_analysis:
  colors:
    scan_all_files:
      - "src/**/*.tsx"
      - "src/**/*.jsx"
      - "src/**/*.css"
    detect:
      token_usage: "var(--color-*), text-{color}, bg-{color}, border-{color}"
      hardcoded_hex: "#[0-9a-fA-F]{3,8} in className or style"
      hardcoded_rgb: "rgb(a?) literals"
      hardcoded_hsl: "hsl(a?) literals"
    build:
      palette_real: "All unique colors actually used"
      palette_tokens: "Colors defined in tokens/config"
      violations: "Hardcoded colors not matching any token"
      most_used: "Top 10 colors by frequency"
      orphan_tokens: "Tokens defined but never used"

  spacing:
    detect:
      token_usage: "gap-{n}, p-{n}, m-{n}, space-{n}, var(--spacing-*)"
      hardcoded_px: "Numeric px values in padding/margin/gap"
      hardcoded_rem: "Custom rem values not in scale"
    build:
      scale_real: "All spacing values actually used"
      scale_defined: "Spacing values in tokens/config"
      violations: "Values outside the defined scale"
      most_used: "Top 10 spacing values"

  typography:
    detect:
      font_families: "font-*, fontFamily in tailwind classes or CSS"
      font_sizes: "text-{size}, font-size values"
      font_weights: "font-{weight}, font-weight values"
      line_heights: "leading-{n}, line-height values"
    build:
      type_scale_real: "All font sizes actually used"
      type_scale_defined: "Font sizes in tokens/config"
      families_used: "Font families in use"
      violations: "Font sizes outside the scale"

  breakpoints:
    detect:
      tailwind: "sm:, md:, lg:, xl:, 2xl: prefixes in className"
      media_queries: "@media (min-width: *) or (max-width: *)"
      container_queries: "@container queries"
    build:
      breakpoints_defined: "Breakpoints in tailwind config or CSS"
      breakpoints_used: "Breakpoints actually referenced in code"
      unused_breakpoints: "Defined but never used"
      custom_breakpoints: "Media queries not matching defined breakpoints"

  z_index:
    detect: "z-{n}, z-index values in CSS or className"
    build:
      z_scale: "All z-index values used, sorted"
      conflicts: "Same z-index on unrelated components"
      chaos_score: "Number of unique z-index values (>10 = chaos)"

  border_radius:
    detect: "rounded-{n}, border-radius values"
    build:
      radius_scale: "All border-radius values used"
      violations: "Values outside defined tokens"
```

### Phase 3: Consistency Analysis

```yaml
consistency:
  scoring:
    token_adherence:
      formula: "(token_usages / total_usages) * 100"
      per_category: "colors, spacing, typography, radius separately"
      overall: "weighted average"

    thresholds:
      excellent: ">= 90% token usage"
      good: "75-89%"
      needs_work: "50-74%"
      poor: "< 50%"

  detect_patterns:
    dominant_pattern:
      definition: "Value used in 80%+ of cases in a category"
      action: "Report as established convention"

    outliers:
      definition: "Value used only 1-2 times"
      action: "Flag as candidate for token alignment"

    near_duplicates:
      definition: "Two colors within 5% HSL distance"
      action: "Suggest consolidating to one token"
      example: "#1a1a2e and #1b1b2f → probably the same intent"

    inconsistent_naming:
      definition: "Mix of naming patterns (--color-primary vs --primary-color)"
      action: "Flag naming convention inconsistency"
```

### Phase 4: Generate Report

```yaml
report:
  design_system_score:
    formula: >
      (color_adherence * 0.3) + (spacing_adherence * 0.25) +
      (typography_adherence * 0.2) + (radius_adherence * 0.1) +
      (z_index_order * 0.05) + (breakpoint_coverage * 0.1)
    max: 100
    thresholds:
      solid: ">= 80 — design system well established"
      emerging: "50-79 — design system in progress, some gaps"
      adhoc: "< 50 — no consistent design system"
```

---

## Output Format

```
DESIGN SYSTEM DISCOVERY
========================
Project: {name}
Design Language: {glass_morphism | material | flat | custom}
DS Score: {score}/100 ({solid | emerging | adhoc})
Styling: {Tailwind | CSS Modules | styled-components | CSS vars}

TOKEN INVENTORY
----------------
Category     | Defined | Used  | Adherence | Violations
-------------|---------|-------|-----------|----------
Colors       | 12      | 18    | 78%       | 6 hardcoded
Spacing      | 8       | 11    | 85%       | 3 hardcoded
Typography   | 5       | 7     | 71%       | 2 outside scale
Radius       | 4       | 4     | 100%      | 0
Z-index      | —       | 8     | —         | chaos (8 values)
Breakpoints  | 4       | 3     | 75%       | 1 unused (2xl)

COLOR PALETTE (real usage)
---------------------------
 Token colors (12):
   --glass-bg ........... 24 uses
   --glass-border ....... 18 uses
   --text-primary ....... 15 uses
   ... (top 10)

 Hardcoded violations (6):
   #1a1a2e .............. 4 uses (Header.tsx, Footer.tsx)
     → Suggest: var(--glass-bg) or bg-slate-900
   #10b981 .............. 2 uses (ScheduleForm.tsx)
     → Suggest: text-emerald-500 or var(--color-success)
   ... (all violations)

SPACING SCALE
--------------
 Defined: 4px grid (1, 2, 3, 4, 5, 6, 8, 10, 12, 16)
 Hardcoded violations (3):
   15px ................. 2 uses (ServiceCard.tsx)
     → Suggest: p-4 (16px) — nearest token
   ... (all violations)

TYPOGRAPHY
-----------
 Families: Inter (body), JetBrains Mono (code)
 Scale: text-sm, text-base, text-lg, text-xl, text-2xl
 Violations (2):
   font-size: 13px ...... 1 use (Footer.tsx)
     → Suggest: text-sm (14px)

NEAR-DUPLICATES
----------------
 #1a1a2e ≈ #1b1b2f — HSL distance 1.2% (consolidate?)
 text-slate-400 ≈ text-gray-400 — same intent? (pick one)

========================
Next steps:
  1. Fix 6 hardcoded color violations
  2. Consolidate near-duplicate colors
  3. Add z-index scale tokens (8 raw values → organize)

What do you want to do?
```

---

## Integration with Other Tasks

```yaml
feeds_into:
  apex-suggest:
    what: "Design violations become proactive suggestions"
    how: "Hardcoded values, near-duplicates flagged automatically"

  apex-scan:
    what: "Design language detection enriches project context"
    how: "DS score and language cached with scan results"

  apex-audit:
    what: "Design system health feeds audit report"
    how: "DS score becomes part of project readiness"

  apex-fix:
    what: "Fix knows token names for replacements"
    how: "When fixing hardcoded color, suggest correct token"

  veto_gate_QG-AX-001:
    what: "Token violation gate uses real data"
    how: "Discovery provides exact list of violations for QG-AX-001"

  design-sys-eng:
    what: "Diana receives full design system map"
    how: "No manual exploration needed — data is pre-loaded"

  css-eng:
    what: "Josh knows exact token inventory"
    how: "When writing CSS, uses discovered tokens not guesses"

  smart_defaults:
    what: "Auto-suggest correct token for replacements"
    how: "Hardcoded #1a1a2e → suggest var(--glass-bg) based on nearest match"
```

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-DISC-DS-001
    condition: "No CSS files, no Tailwind config, no theme files"
    action: "WARN — no design system detected, report as adhoc"
    blocking: false
    fallback: "Report inline styles and className patterns as implicit tokens"

  - id: VC-DISC-DS-002
    condition: "Project uses CSS-in-JS exclusively (no CSS/Tailwind)"
    action: "ADAPT — scan theme objects instead of CSS files"
    blocking: false
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | apex-lead (routing), design-sys-eng (design decisions), css-eng (implementation) |
| Next action | User fixes violations, consolidates tokens, or continues to other commands |

---

*Apex Squad — Design System Discovery Task v1.0.0*
