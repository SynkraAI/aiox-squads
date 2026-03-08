# Task: apex-dark-mode-audit

```yaml
id: apex-dark-mode-audit
version: "1.0.0"
title: "Apex Dark Mode Audit"
description: >
  Validates dark mode implementation across the project. Checks token coverage,
  contrast ratios in dark theme, image/shadow inversion, hardcoded colors that
  break in dark mode, and component-level dark mode testing.
elicit: true
owner: apex-lead
executor: apex-lead
dependencies:
  - tasks/theme-audit.md
  - tasks/accessibility-audit.md
  - checklists/multi-mode-checklist.md
outputs:
  - Dark mode audit report with pass/fail per check
  - List of components that break in dark mode
  - Fix plan with token replacements
```

---

## Command

### `*apex-dark-mode`

Audits dark mode implementation for the entire project or specific components.

---

## How It Works

### Step 1: Detect Dark Mode Implementation

```yaml
detection:
  strategies:
    - css_media: "prefers-color-scheme: dark"
    - css_class: ".dark, [data-theme='dark'], [data-mode='dark']"
    - tailwind: "dark: prefix in classes"
    - css_variables: "Separate variable sets for light/dark"
    - react_context: "ThemeProvider, useTheme, colorScheme"
    - native: "useColorScheme (React Native)"

  result:
    - if: "No dark mode detected"
      action: "Report: Dark mode not implemented. Suggest implementation plan."
    - if: "Partial implementation"
      action: "Audit what exists, flag gaps."
    - if: "Full implementation"
      action: "Full audit across all checks."
```

### Step 2: Multi-Dimensional Audit

```yaml
audit_checks:

  token_coverage:
    agent: "@design-sys-eng"
    checks:
      - All semantic color tokens have dark variants
      - Background tokens switch correctly (no white backgrounds in dark)
      - Text tokens maintain readable contrast in dark
      - Border/divider tokens adapt to dark
      - Shadow tokens adjust (lighter/subtler in dark, not darker)
      - No orphaned tokens (defined in light but missing in dark)
    severity_if_fail: HIGH

  contrast_validation:
    agent: "@a11y-eng"
    checks:
      - Text/background contrast >= 4.5:1 in dark mode (WCAG AA)
      - Large text contrast >= 3:1 in dark mode
      - UI component contrast >= 3:1 against dark backgrounds
      - Focus indicators visible against dark backgrounds
      - Disabled state still distinguishable in dark
      - Link colors distinguishable from body text in dark
    severity_if_fail: CRITICAL

  hardcoded_colors:
    agent: "@css-eng"
    checks:
      - No hardcoded white (#fff, #ffffff, white) in components
      - No hardcoded dark text (#000, #333) without token
      - No hardcoded backgrounds that ignore theme
      - No inline styles with fixed colors
      - Box shadows with hardcoded dark colors
    severity_if_fail: HIGH

  image_and_media:
    agent: "@css-eng"
    checks:
      - Images with white backgrounds have dark-mode treatment
      - SVG icons use currentColor (adapt to theme)
      - Logos have dark-mode variants if needed
      - Screenshots/illustrations adapt or have overlay
      - Favicons/og-images dark variants exist
    severity_if_fail: MEDIUM

  component_specific:
    agent: "@react-eng"
    checks:
      - Forms — input backgrounds, borders, placeholder text
      - Modals — overlay opacity, content background
      - Dropdowns — list backgrounds, hover states
      - Toasts/alerts — severity colors in dark context
      - Code blocks — syntax highlighting adapts
      - Tables — alternating row colors adapt
      - Charts — colors readable against dark background
    severity_if_fail: HIGH

  transition_quality:
    agent: "@motion-eng"
    checks:
      - Theme switch animation exists (not jarring instant switch)
      - No flash of wrong theme on page load (FOIT equivalent)
      - Transition duration appropriate (150-300ms)
      - System preference change detected in real-time
    severity_if_fail: MEDIUM
```

### Step 3: Generate Report

```yaml
report_format: |
  ## Dark Mode Audit

  **Implementation:** {none|partial|full}
  **Strategy:** {css_media|css_class|tailwind|css_variables}

  ### Results

  | Check | Status | Issues | Severidade |
  |-------|--------|--------|------------|
  | Token coverage | {PASS|FAIL} | {count} | {sev} |
  | Contrast (dark) | {PASS|FAIL} | {count} | {sev} |
  | Hardcoded colors | {PASS|FAIL} | {count} | {sev} |
  | Images/media | {PASS|FAIL} | {count} | {sev} |
  | Components | {PASS|FAIL} | {count} | {sev} |
  | Transition | {PASS|FAIL} | {count} | {sev} |

  ### Components que quebram em dark mode
  | Componente | Problema | Fix |
  |-----------|----------|-----|
  | {name} | {issue} | {suggested fix} |

  ### Token replacements necessarios
  | Valor hardcoded | Token correto | Arquivos |
  |-----------------|---------------|----------|
  | {value} | {token} | {files} |
```

### Step 4: Options

```yaml
options:
  1_fix_all:
    label: "Corrigir tudo ({total} issues)"
    action: "Route to *apex-quick with fix plan"

  2_fix_critical:
    label: "So contraste (CRITICAL)"
    action: "Route to *apex-fix for contrast fixes"

  3_tokens_only:
    label: "Substituir hardcoded por tokens"
    action: "Route to *apex-fix for token replacements"

  4_report:
    label: "So o relatorio"
    action: "End"
```

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-DM-001
    condition: "Dark mode contrast below WCAG AA (4.5:1)"
    action: "VETO — Contrast must meet AA in both light AND dark modes."
    available_check: "manual"
    on_unavailable: MANUAL_CHECK
```

---

*Apex Squad — Dark Mode Audit Task v1.0.0*
