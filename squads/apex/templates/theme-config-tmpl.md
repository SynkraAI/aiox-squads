# Theme Configuration: {ThemeName}

**Date:** {YYYY-MM-DD}
**Author:** @design-sys-eng (Diana)
**Reviewed By:** @a11y-eng (Ada), @apex-lead (Emil)
**Status:** Draft | In Review | Approved

## Theme Name

{ThemeName} — {brief description of the theme purpose and scope}

## Mode Definitions

| Mode | Data Attribute | Description | Primary Use Case |
|------|---------------|-------------|-----------------|
| Light | `data-theme="light"` | Default light appearance | Standard usage, well-lit environments |
| Dark | `data-theme="dark"` | Dark appearance | Low-light environments, user preference |
| High Contrast | `data-theme="high-contrast"` | Enhanced contrast on light background | WCAG AAA compliance, visual impairment |
| Dark High Contrast | `data-theme="dark-high-contrast"` | Enhanced contrast on dark background | Low-light + visual impairment |

## Token Mapping

### Color Tokens
| Token Name | Light | Dark | High Contrast | Dark High Contrast |
|------------|-------|------|:-------------:|:------------------:|
| `--color-bg-primary` | {#ffffff} | {#0a0a0a} | {#ffffff} | {#000000} |
| `--color-bg-secondary` | {#f5f5f5} | {#171717} | {#f0f0f0} | {#0a0a0a} |
| `--color-bg-tertiary` | {#e5e5e5} | {#262626} | {#e0e0e0} | {#1a1a1a} |
| `--color-text-primary` | {#171717} | {#fafafa} | {#000000} | {#ffffff} |
| `--color-text-secondary` | {#525252} | {#a3a3a3} | {#1a1a1a} | {#e5e5e5} |
| `--color-text-muted` | {#737373} | {#737373} | {#404040} | {#c0c0c0} |
| `--color-border-default` | {#e5e5e5} | {#2e2e2e} | {#000000} | {#ffffff} |
| `--color-border-strong` | {#a3a3a3} | {#525252} | {#000000} | {#ffffff} |
| `--color-accent-primary` | {#2563eb} | {#3b82f6} | {#0000cc} | {#6699ff} |
| `--color-accent-hover` | {#1d4ed8} | {#60a5fa} | {#000099} | {#99bbff} |
| `--color-focus-ring` | {#2563eb80} | {#3b82f680} | {#000000} | {#ffffff} |
| `--color-error` | {#dc2626} | {#ef4444} | {#cc0000} | {#ff6666} |
| `--color-success` | {#16a34a} | {#22c55e} | {#006600} | {#66cc66} |
| `--color-warning` | {#ca8a04} | {#eab308} | {#996600} | {#ffcc33} |

### Surface & Elevation Tokens
| Token Name | Light | Dark | Notes |
|------------|-------|------|-------|
| `--shadow-sm` | {0 1px 2px rgba(0,0,0,0.05)} | {0 1px 2px rgba(0,0,0,0.3)} | {Cards, buttons} |
| `--shadow-md` | {0 4px 6px rgba(0,0,0,0.07)} | {0 4px 6px rgba(0,0,0,0.4)} | {Dropdowns, popovers} |
| `--shadow-lg` | {0 10px 15px rgba(0,0,0,0.1)} | {0 10px 15px rgba(0,0,0,0.5)} | {Modals, dialogs} |
| `--surface-overlay` | {rgba(0,0,0,0.5)} | {rgba(0,0,0,0.7)} | {Backdrop behind modals} |

## CSS Implementation

### Data-Attribute Switching
```css
:root,
[data-theme="light"] {
  --color-bg-primary: #ffffff;
  --color-text-primary: #171717;
  /* ... all light tokens */
}

[data-theme="dark"] {
  --color-bg-primary: #0a0a0a;
  --color-text-primary: #fafafa;
  /* ... all dark tokens */
}

[data-theme="high-contrast"] {
  --color-bg-primary: #ffffff;
  --color-text-primary: #000000;
  /* ... all high contrast tokens */
}

[data-theme="dark-high-contrast"] {
  --color-bg-primary: #000000;
  --color-text-primary: #ffffff;
  /* ... all dark high contrast tokens */
}
```

### System Preference Detection
```css
@media (prefers-color-scheme: dark) {
  :root:not([data-theme]) {
    /* Apply dark tokens when no explicit theme set */
  }
}

@media (prefers-contrast: more) {
  :root:not([data-theme]) {
    /* Apply high contrast tokens when no explicit theme set */
  }
}
```

### Theme Switching (JavaScript)
```typescript
function setTheme(theme: 'light' | 'dark' | 'high-contrast' | 'dark-high-contrast') {
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem('preferred-theme', theme);
}

function getSystemTheme(): string {
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  const prefersContrast = window.matchMedia('(prefers-contrast: more)').matches;

  if (prefersDark && prefersContrast) return 'dark-high-contrast';
  if (prefersDark) return 'dark';
  if (prefersContrast) return 'high-contrast';
  return 'light';
}
```

## Testing Requirements

### Per-Mode Testing
- [ ] **Light mode:** All components visually correct, contrast AA compliant
- [ ] **Dark mode:** All components visually correct, no white flashes on load
- [ ] **High contrast:** All text/border contrast >= 7:1 (AAA), focus indicators visible
- [ ] **Dark high contrast:** All text/border contrast >= 7:1 (AAA), no invisible elements

### Mode Switching
- [ ] Switching from light to dark: no layout shift, smooth transition
- [ ] Switching from dark to light: no flash of unstyled content
- [ ] Theme persists across page navigation (localStorage)
- [ ] System preference change is detected and applied (if no manual override)

### Contrast Ratios (WCAG)
| Element | Light (ratio) | Dark (ratio) | HC (ratio) | DHC (ratio) |
|---------|:---:|:---:|:---:|:---:|
| Primary text on bg | [ ] >= 4.5:1 | [ ] >= 4.5:1 | [ ] >= 7:1 | [ ] >= 7:1 |
| Secondary text on bg | [ ] >= 4.5:1 | [ ] >= 4.5:1 | [ ] >= 7:1 | [ ] >= 7:1 |
| Accent on bg | [ ] >= 3:1 | [ ] >= 3:1 | [ ] >= 4.5:1 | [ ] >= 4.5:1 |
| Error text on bg | [ ] >= 4.5:1 | [ ] >= 4.5:1 | [ ] >= 7:1 | [ ] >= 7:1 |
| Focus ring visibility | [ ] visible | [ ] visible | [ ] visible | [ ] visible |

### Platform Testing
- [ ] Web (Next.js): Server-rendered theme matches client hydration
- [ ] Mobile (React Native): Theme tokens applied via StyleSheet
- [ ] Storybook: Theme switcher addon configured and functional

## References
- Design tokens source: {Figma URL or token file path}
- WCAG contrast requirements: https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum
- `prefers-contrast` spec: https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-contrast
