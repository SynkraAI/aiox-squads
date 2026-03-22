# Layout Strategy: {Feature / Component / Page Name}

**Date:** {YYYY-MM-DD}
**Author:** @interaction-dsgn (Isa)
**Reviewed By:** @css-eng (Cleo), @apex-lead (Emil)
**Status:** Draft | In Review | Approved

## Layout Overview

{One paragraph describing the layout goal: what content is arranged, the spatial relationships, and the user experience intent.}

## Algorithm Choice

**Primary:** {CSS Grid | Flexbox | CSS Flow Layout}
**Secondary (if hybrid):** {Flexbox for children | Grid for page structure}

### Rationale
{Why this algorithm over alternatives. Consider:}
- {2D vs 1D layout needs}
- {Content-driven vs container-driven sizing}
- {Alignment complexity}
- {Browser support requirements}

### Layout Skeleton
```css
.{layout-name} {
  display: {grid | flex};
  /* Key structural properties */
}

/* Named areas (if Grid) */
.{layout-name} {
  grid-template-areas:
    "{area-1} {area-2}"
    "{area-3} {area-4}";
  grid-template-columns: {column definitions};
  grid-template-rows: {row definitions};
  gap: var(--spacing-{n});
}
```

## Container Query Plan

### Container Contexts
| Container Name | Element | container-type | Purpose |
|---------------|---------|---------------|---------|
| {name} | .{selector} | inline-size | {what it controls} |
| {name} | .{selector} | inline-size | {what it controls} |

### Breakpoints
| Container | Threshold | Layout Change |
|-----------|-----------|---------------|
| {name} | < 300px | {stacked, single column, hidden elements} |
| {name} | 300px - 600px | {default layout} |
| {name} | > 600px | {expanded, additional columns, revealed elements} |

### Container Query CSS
```css
@container {name} (max-width: 300px) {
  .{child} {
    /* compact layout rules */
  }
}

@container {name} (min-width: 600px) {
  .{child} {
    /* expanded layout rules */
  }
}
```

## Responsive Behavior

### Mobile (< 640px)
- Layout: {description}
- Columns: {1 column typically}
- Hidden elements: {what is removed or collapsed}
- Touch targets: {minimum 44x44px}

### Tablet (640px - 1024px)
- Layout: {description}
- Columns: {2 columns typically}
- Sidebar behavior: {collapsed / overlay / visible}

### Desktop (> 1024px)
- Layout: {description}
- Columns: {full layout}
- Max-width: {container max-width, e.g. 1280px}
- Centering: {margin auto or grid placement}

## Defensive CSS Applied

| Pattern | CSS Rule | Purpose |
|---------|----------|---------|
| Overflow protection | `overflow-wrap: break-word` | Prevent long strings from breaking layout |
| Flex shrink guard | `min-width: 0` on flex children | Prevent flex items from overflowing |
| Image aspect ratio | `aspect-ratio: {w}/{h}; object-fit: cover` | Prevent layout shift from images |
| Grid min sizing | `minmax(0, 1fr)` instead of `1fr` | Prevent grid blowout from content |
| Scroll containment | `overscroll-behavior: contain` | Prevent scroll chaining |
| Safe alignment | `align-items: safe center` | Prevent overflow from centering |

## Testing Matrix

### Viewport Tests
| Viewport | Content: Minimal | Content: Typical | Content: Maximum |
|----------|:---:|:---:|:---:|
| 320px (small mobile) | [ ] | [ ] | [ ] |
| 375px (iPhone) | [ ] | [ ] | [ ] |
| 768px (tablet) | [ ] | [ ] | [ ] |
| 1024px (small desktop) | [ ] | [ ] | [ ] |
| 1440px (desktop) | [ ] | [ ] | [ ] |
| 2560px (ultrawide) | [ ] | [ ] | [ ] |

### Additional Checks
- [ ] RTL layout (direction: rtl) renders correctly
- [ ] 200% browser zoom does not break layout
- [ ] Container queries fire at correct thresholds
- [ ] No horizontal scrollbar at any viewport
- [ ] Print layout is acceptable (or hidden)

## References
- Figma: {URL to layout frames}
- ADR: {link to relevant architecture decision if exists}
