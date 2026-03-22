# Component Design: {ComponentName}

**Date:** {YYYY-MM-DD}
**Designer:** @interaction-dsgn (Isa)
**Reviewed By:** @apex-lead (Emil)
**Status:** Draft | In Review | Approved

## Purpose

{One paragraph describing what this component does, where it appears, and why it exists.}

## Content Variations

| Variation | Description | Design Consideration |
|-----------|-------------|---------------------|
| Short text | {1-2 words, e.g. "OK"} | {Min-width needed? Centering?} |
| Long text | {50+ chars, wrapping expected} | {Truncation? Tooltip? Multiline?} |
| With image | {Image present and loaded} | {Aspect ratio, loading state?} |
| Without image | {Image missing or errored} | {Fallback placeholder? Layout shift?} |
| Optional fields hidden | {Non-required content absent} | {Collapse space? Show skeleton?} |
| Maximum content | {All fields at max length/count} | {Overflow strategy?} |
| Minimum content | {Only required fields, minimal data} | {Empty state distinct from loading?} |

## Layout Strategy

**Algorithm:** {CSS Grid | Flexbox | Hybrid} — {Rationale for choice}

```css
/* Layout skeleton */
.{component-name} {
  display: {grid | flex};
  /* {key layout properties} */
}
```

### Container Query Breakpoints

| Container Width | Layout Description | Key Changes |
|:-:|---|---|
| < 300px | {Compact/stacked layout} | {What collapses, hides, or reflows} |
| 300px - 500px | {Default layout} | {Standard presentation} |
| > 500px | {Expanded layout} | {What stretches, adds columns, or reveals} |

### Container Context

```css
.{component-name}-wrapper {
  container-type: inline-size;
  container-name: {component-name};
}
```

## Edge Cases

| Case | Expected Behavior |
|------|-------------------|
| Long text (no spaces) | {word-break strategy} |
| Missing images | {fallback: placeholder / icon / hide} |
| RTL languages | {logical properties, mirrored layout} |
| 200% browser zoom | {reflow behavior, no overflow} |
| Reduced motion | {disable animations, instant transitions} |
| High contrast mode | {border fallbacks, forced-colors adjustments} |
| Print | {print-specific styles or hide} |

## Motion Spec

| Trigger | Animation | Duration | Easing |
|---------|-----------|----------|--------|
| Enter | {fade-in, slide-up, scale, etc.} | {ms} | {spring(stiffness, damping) or cubic-bezier} |
| Exit | {fade-out, slide-down, etc.} | {ms} | {spring or cubic-bezier} |
| Hover | {scale, color shift, shadow, etc.} | {ms} | {spring or cubic-bezier} |
| Focus | {ring, outline, glow, etc.} | {ms} | {spring or cubic-bezier} |

### Spring Configuration (if applicable)
```js
{
  stiffness: {number},
  damping: {number},
  mass: {number},
}
```

### Reduced Motion Fallback
{Describe what replaces animations when `prefers-reduced-motion: reduce` is active.
Typically: instant opacity transitions, no transforms.}

## Accessibility

### Focus Management
- Focus indicator: {2px ring using token, visible on all backgrounds}
- Tab order: {describe tab sequence through interactive children}
- Focus trap: {yes/no — if modal or popover}

### Screen Reader
- Role: {ARIA role or native semantic element}
- Label: {aria-label or aria-labelledby strategy}
- Live region: {aria-live for dynamic content updates}
- Announcements: {what is announced on state changes}

### Keyboard Interaction
| Key | Action |
|-----|--------|
| Tab | {move focus to next element} |
| Enter / Space | {activate / toggle} |
| Escape | {close / dismiss if applicable} |
| Arrow keys | {navigate within component if applicable} |

## Design Tokens Referenced
| Token | Usage |
|-------|-------|
| {token-name} | {where it is applied} |
| {token-name} | {where it is applied} |

## Figma Reference
- File: {Figma URL}
- Frame: {specific frame path in Figma}
