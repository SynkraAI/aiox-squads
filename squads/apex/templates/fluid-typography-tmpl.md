# Fluid Typography Scale: {Scale Name}

**Date:** {YYYY-MM-DD}
**Author:** @interaction-dsgn (Isa)
**Reviewed By:** @design-sys-eng (Diana), @apex-lead (Emil)
**Status:** Draft | In Review | Approved

## Type Scale Overview

{Brief description of the typographic scale purpose: brand expression, readability goals, platform coverage.}

### Design Principles
- {e.g., Readability first — body text optimized for long-form reading}
- {e.g., Progressive enhancement — graceful scaling across all viewports}
- {e.g., Accessibility — respects user font-size preferences}

## Viewport Range

| Parameter | Value |
|-----------|-------|
| Minimum viewport width | {320px} |
| Maximum viewport width | {1440px} |
| Base font size (1rem) | {16px} |
| Scale ratio (min) | {1.2 — Minor Third} |
| Scale ratio (max) | {1.25 — Major Third} |

## Scale Definition

| Token Name | Min Size | Preferred (vw calc) | Max Size | `clamp()` Value |
|------------|:--------:|:--------------------:|:--------:|-----------------|
| `--text-xs` | {12px} | {calc expression} | {14px} | `clamp(0.75rem, 0.7rem + 0.25vw, 0.875rem)` |
| `--text-sm` | {14px} | {calc expression} | {16px} | `clamp(0.875rem, 0.83rem + 0.25vw, 1rem)` |
| `--text-base` | {16px} | {calc expression} | {18px} | `clamp(1rem, 0.95rem + 0.25vw, 1.125rem)` |
| `--text-lg` | {18px} | {calc expression} | {22px} | `clamp(1.125rem, 1rem + 0.5vw, 1.375rem)` |
| `--text-xl` | {20px} | {calc expression} | {28px} | `clamp(1.25rem, 1.05rem + 1vw, 1.75rem)` |
| `--text-2xl` | {24px} | {calc expression} | {36px} | `clamp(1.5rem, 1.15rem + 1.5vw, 2.25rem)` |
| `--text-3xl` | {30px} | {calc expression} | {48px} | `clamp(1.875rem, 1.3rem + 2.5vw, 3rem)` |
| `--text-4xl` | {36px} | {calc expression} | {60px} | `clamp(2.25rem, 1.4rem + 3.5vw, 3.75rem)` |
| `--text-5xl` | {48px} | {calc expression} | {80px} | `clamp(3rem, 1.6rem + 5vw, 5rem)` |

> **Formula:** `clamp(min, preferred, max)` where preferred = `minSize + (maxSize - minSize) * ((100vw - minVW) / (maxVW - minVW))`

## Line Height Scale

| Token Name | Line Height | Usage |
|------------|:-----------:|-------|
| `--leading-tight` | {1.1} | {Display headings} |
| `--leading-snug` | {1.3} | {Subheadings, short text} |
| `--leading-normal` | {1.5} | {Body text} |
| `--leading-relaxed` | {1.65} | {Long-form reading, small text} |
| `--leading-loose` | {1.8} | {Captions at small sizes} |

## Letter Spacing Scale

| Token Name | Value | Usage |
|------------|:-----:|-------|
| `--tracking-tighter` | {-0.02em} | {Large display text} |
| `--tracking-tight` | {-0.01em} | {Headings} |
| `--tracking-normal` | {0} | {Body text} |
| `--tracking-wide` | {0.025em} | {Labels, buttons, uppercase} |
| `--tracking-wider` | {0.05em} | {All-caps headings} |

## Usage Guidelines

### Semantic Mapping
| Semantic Role | Token | Line Height | Letter Spacing |
|---------------|-------|:-----------:|:--------------:|
| Page title | `--text-4xl` | `--leading-tight` | `--tracking-tighter` |
| Section heading | `--text-2xl` | `--leading-snug` | `--tracking-tight` |
| Card title | `--text-xl` | `--leading-snug` | `--tracking-normal` |
| Body text | `--text-base` | `--leading-normal` | `--tracking-normal` |
| Caption | `--text-sm` | `--leading-relaxed` | `--tracking-normal` |
| Label / Badge | `--text-xs` | `--leading-normal` | `--tracking-wide` |

### CSS Custom Property Usage
```css
.heading {
  font-size: var(--text-2xl);
  line-height: var(--leading-snug);
  letter-spacing: var(--tracking-tight);
}

.body {
  font-size: var(--text-base);
  line-height: var(--leading-normal);
  letter-spacing: var(--tracking-normal);
}
```

## Testing

### Viewport Extremes
- [ ] **320px viewport:** All text tokens render at minimum size, no overflow
- [ ] **2560px viewport:** All text tokens render at maximum size (clamped), no excessive scaling
- [ ] **Intermediate viewports (768px, 1024px):** Fluid interpolation is smooth

### User Preferences
- [ ] **User font-size 200%:** Layout accommodates doubled text without breakage
- [ ] **User font-size 50%:** Text remains legible, minimum sizes respected
- [ ] **`prefers-reduced-data`:** Webfont fallback does not shift layout

### Cross-Browser
- [ ] Chrome: `clamp()` renders correctly
- [ ] Firefox: `clamp()` renders correctly
- [ ] Safari: `clamp()` renders correctly
- [ ] Mobile Safari / Chrome: Viewport units behave as expected

### Accessibility
- [ ] All body text >= 16px equivalent at default viewport
- [ ] Contrast ratio meets WCAG AA at all scale sizes
- [ ] Line height >= 1.5 for body text (WCAG 1.4.12)
- [ ] Letter spacing not reduced below browser default for body text

## References
- Figma typography styles: {link}
- Type scale calculator: {link, e.g. utopia.fyi}
- WCAG 1.4.12 Text Spacing: https://www.w3.org/WAI/WCAG21/Understanding/text-spacing
