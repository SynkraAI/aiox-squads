# Task: apex-export-tokens

```yaml
id: apex-export-tokens
version: "1.0.0"
title: "Apex Export Tokens"
description: >
  Exports design tokens from the project into designer-friendly formats:
  Figma variables JSON, Style Dictionary config, CSS custom properties,
  Tailwind config, or plain documentation. Bridges the gap between
  code tokens and design tool tokens.
elicit: true
owner: design-sys-eng
executor: design-sys-eng
dependencies:
  - tasks/apex-discover-design.md
  - data/design-tokens-map.yaml
outputs:
  - Exported token file in chosen format
  - Token documentation with usage examples
```

---

## Command

### `*apex-export-tokens {format}`

Exports project tokens to specified format.

---

## Supported Formats

```yaml
formats:
  figma:
    extension: ".json"
    description: "Figma Variables JSON — importable via Figma plugin"
    structure: |
      {
        "colors": { "primary": { "value": "#3B82F6", "type": "color" } },
        "spacing": { "sm": { "value": "8", "type": "spacing" } },
        "typography": { "body": { "value": { "fontFamily": "Inter", "fontSize": 16 }, "type": "typography" } }
      }

  style_dictionary:
    extension: ".json"
    description: "Style Dictionary format — multi-platform token build"
    structure: |
      {
        "color": { "primary": { "value": "#3B82F6" } },
        "spacing": { "sm": { "value": "8px" } }
      }

  css:
    extension: ".css"
    description: "CSS Custom Properties — ready to paste"
    structure: |
      :root {
        --color-primary: #3B82F6;
        --spacing-sm: 8px;
      }

  tailwind:
    extension: ".js"
    description: "Tailwind config extend — merge into tailwind.config"
    structure: |
      module.exports = {
        theme: { extend: { colors: { primary: '#3B82F6' } } }
      }

  markdown:
    extension: ".md"
    description: "Documentation — human-readable token reference"
    structure: "Table with token name, value, usage, preview"
```

### Step 1: Discover Tokens

```yaml
discovery:
  action: "Run *discover-design if no cache exists"
  extract:
    - CSS custom properties (--var-name)
    - Tailwind config values
    - Theme object values (JS/TS)
    - Hardcoded values that SHOULD be tokens (flagged)
  categorize:
    - colors (palette, semantic, component-specific)
    - typography (font family, size scale, weight, line height)
    - spacing (padding/margin/gap scale)
    - radius (border-radius scale)
    - shadows (elevation levels)
    - motion (spring configs, durations)
    - breakpoints (responsive breakpoints)
    - z-index (stacking order)
```

### Step 2: Transform and Export

```yaml
transform:
  rules:
    - Normalize values (hex → consistent format, px → rem if configured)
    - Group by category
    - Include both light and dark variants
    - Add descriptions from usage context
    - Flag tokens with low usage (potentially unused)
```

### Step 3: Options

```yaml
options:
  1_export:
    label: "Exportar em {format}"
    action: "Generate file, save to project root or specified path"

  2_multi:
    label: "Exportar em multiplos formatos"
    action: "Generate all selected formats"

  3_sync:
    label: "Setup sync automatico (Style Dictionary pipeline)"
    action: "Configure Style Dictionary for continuous token build"

  4_docs:
    label: "Gerar documentacao de tokens"
    action: "Generate markdown doc with previews"
```

---

*Apex Squad — Export Tokens Task v1.0.0*
