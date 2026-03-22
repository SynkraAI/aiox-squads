# Task: apex-discover-a11y

```yaml
id: apex-discover-a11y
version: "1.0.0"
title: "Apex Discover Accessibility"
description: >
  Static accessibility scan across all components. Detects missing alt texts,
  form labels, color contrast issues, keyboard traps, ARIA misuse, and focus
  management gaps WITHOUT running axe-core. Code-level analysis that feeds
  accessibility-audit and veto QG-AX-005.
elicit: false
owner: apex-lead
executor: a11y-eng
dependencies:
  - tasks/apex-scan.md
  - tasks/accessibility-audit.md
  - tasks/focus-management-design.md
  - tasks/screen-reader-testing.md
outputs:
  - Accessibility issue inventory
  - Component-level a11y status
  - A11y health score
```

---

## Command

### `*discover-a11y`

Static accessibility scan across all components (no browser needed).

---

## How It Works

### Step 1: Scan All Components

```yaml
scan:
  targets:
    - "All .tsx/.jsx files in src/"
    - "All .css/.scss files"
    - "tailwind.config.* for color definitions"

  exclude:
    - "test files (*.test.*, *.spec.*)"
    - "storybook files (*.stories.*)"
    - "node_modules/"
    - "build/dist output"
```

### Step 2: Check Categories

```yaml
checks:

  images_and_media:
    description: "Images without text alternatives"
    patterns:
      - "<img without alt"
      - "<img alt='' (empty alt on non-decorative)"
      - "background-image with informational content"
      - "<svg without aria-label or title"
      - "<video without captions track"
      - "<audio without transcript reference"
    wcag: "1.1.1 Non-text Content (A)"
    severity: HIGH

  form_labels:
    description: "Form inputs without associated labels"
    patterns:
      - "<input without id+label or aria-label or aria-labelledby"
      - "<select without label"
      - "<textarea without label"
      - "Placeholder used as only label"
      - "Custom input component without forwarded aria props"
    wcag: "1.3.1 Info and Relationships (A), 4.1.2 Name Role Value (A)"
    severity: HIGH

  color_contrast:
    description: "Text/background combinations with insufficient contrast"
    detection:
      - "Extract text color + background color from component"
      - "Calculate contrast ratio"
      - "Flag if < 4.5:1 for normal text"
      - "Flag if < 3:1 for large text (18px+ or 14px+ bold)"
    limitations: "Static analysis — may miss dynamic colors, runtime themes"
    wcag: "1.4.3 Contrast Minimum (AA)"
    severity: HIGH

  keyboard_navigation:
    description: "Interactive elements not keyboard accessible"
    patterns:
      - "onClick on <div>, <span> without role='button' + tabIndex + onKeyDown"
      - "Custom dropdown without keyboard support"
      - "Modal without focus trap (focus-trap-react, react-aria)"
      - "Drawer/sidebar without Escape key handler"
      - "Carousel without arrow key navigation"
      - "tabIndex > 0 (disrupts natural tab order)"
    wcag: "2.1.1 Keyboard (A), 2.1.2 No Keyboard Trap (A)"
    severity: CRITICAL

  aria_usage:
    description: "Incorrect or missing ARIA attributes"
    patterns:
      - "role='button' without tabIndex={0}"
      - "aria-hidden='true' on focusable element"
      - "aria-expanded without corresponding collapsible region"
      - "aria-controls pointing to non-existent id"
      - "role='list' on non-list element without listitem children"
      - "aria-label duplicating visible text (redundant)"
      - "Missing aria-live on dynamic content regions"
    wcag: "4.1.2 Name Role Value (A)"
    severity: HIGH

  heading_structure:
    description: "Heading hierarchy issues"
    patterns:
      - "Skipped heading level (h1 → h3, no h2)"
      - "Multiple h1 on same page"
      - "No h1 on page"
      - "Heading used for styling only (should be styled div)"
      - "Non-heading styled to look like heading"
    wcag: "1.3.1 Info and Relationships (A)"
    severity: MEDIUM

  focus_management:
    description: "Missing focus management in dynamic content"
    patterns:
      - "Modal opens without moving focus to modal"
      - "Modal closes without returning focus to trigger"
      - "Route change without focus management"
      - "Dynamic content added without aria-live"
      - "Toast/notification without role='alert' or aria-live"
      - "Infinite scroll without focus anchor"
    wcag: "2.4.3 Focus Order (A)"
    severity: HIGH

  touch_targets:
    description: "Interactive elements too small for touch"
    detection:
      - "Buttons/links with explicit width/height < 44px"
      - "Icon-only buttons without adequate padding"
      - "Close buttons (X) smaller than 44x44"
    wcag: "2.5.8 Target Size Minimum (AA)"
    severity: MEDIUM
```

### Step 3: Calculate A11y Health Score

```yaml
health_score:
  formula: "100 - (penalties)"
  penalties:
    critical_keyboard_trap: -15 each
    missing_alt: -5 each
    missing_form_label: -5 each
    low_contrast: -5 each
    aria_misuse: -3 each
    heading_skip: -2 each
    missing_focus_management: -5 each
    small_touch_target: -2 each

  classification:
    90-100: "accessible — strong a11y foundation"
    70-89: "good — some gaps to address"
    50-69: "needs_work — significant barriers present"
    0-49: "inaccessible — major barriers for users with disabilities"
```

### Step 4: Output

```yaml
output_format: |
  ## Accessibility Discovery

  **Components Scanned:** {total}
  **A11y Health Score:** {score}/100 ({classification})
  **WCAG Level Target:** AA

  ### Issues by Category
  | Category | Count | Severity | WCAG |
  |----------|-------|----------|------|
  | Keyboard navigation | {n} | CRITICAL | 2.1.1 |
  | Missing alt text | {n} | HIGH | 1.1.1 |
  | Missing form labels | {n} | HIGH | 1.3.1 |
  | Color contrast | {n} | HIGH | 1.4.3 |
  | ARIA misuse | {n} | HIGH | 4.1.2 |
  | Focus management | {n} | HIGH | 2.4.3 |
  | Heading structure | {n} | MEDIUM | 1.3.1 |
  | Touch targets | {n} | MEDIUM | 2.5.8 |

  ### Worst Offenders (components with most issues)
  | Component | Issues | Categories |
  |-----------|--------|------------|
  | {name} | {count} | {categories} |

  ### Options
  1. Corrigir CRITICAL ({critical_count} keyboard issues)
  2. Corrigir todos os HIGH ({high_count})
  3. Rodar audit completo com axe-core
  4. So quero o relatorio
```

---

## Veto Conditions

```yaml
veto_conditions:
  - id: VC-DA-001
    condition: "Keyboard trap detected (modal/drawer without escape or focus trap)"
    action: "VETO — Keyboard traps are WCAG 2.1.2 Level A violations. Fix immediately."
    available_check: "manual"
    on_unavailable: MANUAL_CHECK

  - id: VC-DA-002
    condition: "Interactive div/span without keyboard support"
    action: "WARN — Add role, tabIndex, and keyboard handler or use <button>."
    available_check: "manual"
    on_unavailable: MANUAL_CHECK
```

---

## Cache

```yaml
cache:
  location: ".aios/apex-context/a11y-cache.yaml"
  ttl: "Until component files change"
  invalidate_on:
    - "Any .tsx/.jsx file modified"
    - "Any .css file modified"
    - "User runs *discover-a11y explicitly"
```

---

*Apex Squad — Discover Accessibility Task v1.0.0*
