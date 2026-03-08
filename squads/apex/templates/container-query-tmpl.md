# Container Query Pattern: {ComponentName}

**Date:** {YYYY-MM-DD}
**Author:** @interaction-dsgn (Isa)
**Reviewed By:** @css-eng (Cleo)
**Status:** Draft | In Review | Approved

## Component Name

{ComponentName} — {brief one-line description}

## Container Context

| Property | Value |
|----------|-------|
| Parent element | `.{parent-selector}` |
| container-type | `inline-size` |
| container-name | `{component-name}` |

### Setup CSS
```css
.{parent-selector} {
  container-type: inline-size;
  container-name: {component-name};
}
```

## Breakpoints

| Threshold | Layout Description | Key CSS Rules |
|:-:|---|---|
| < 200px | {Micro layout — icon only, minimal text} | `flex-direction: column; font-size: var(--text-xs);` |
| 200px - 300px | {Compact — stacked, single column} | `flex-direction: column; gap: var(--spacing-2);` |
| 300px - 500px | {Default — standard component layout} | `flex-direction: row; gap: var(--spacing-4);` |
| 500px - 700px | {Comfortable — additional content revealed} | `grid-template-columns: 1fr 2fr; gap: var(--spacing-6);` |
| > 700px | {Expanded — full layout with all content visible} | `grid-template-columns: auto 1fr auto; gap: var(--spacing-8);` |

> Adjust thresholds to match the specific component needs. Not all components need all breakpoints.

## Container Query CSS

```css
/* Compact: stacked layout */
@container {component-name} (max-width: 299px) {
  .{component-name}__content {
    flex-direction: column;
    gap: var(--spacing-2);
  }

  .{component-name}__secondary {
    display: none;
  }
}

/* Default layout */
@container {component-name} (min-width: 300px) and (max-width: 499px) {
  .{component-name}__content {
    flex-direction: row;
    align-items: center;
    gap: var(--spacing-4);
  }
}

/* Expanded layout */
@container {component-name} (min-width: 500px) {
  .{component-name}__content {
    display: grid;
    grid-template-columns: auto 1fr auto;
    gap: var(--spacing-6);
  }

  .{component-name}__secondary {
    display: block;
  }
}
```

## Fallback Strategy

For browsers that do not support container queries, provide media query fallbacks.

### Feature Detection
```css
/* Fallback for no container query support */
@supports not (container-type: inline-size) {
  .{component-name}__content {
    /* Use media queries as fallback */
  }

  @media (max-width: 640px) {
    .{component-name}__content {
      flex-direction: column;
      gap: var(--spacing-2);
    }
  }

  @media (min-width: 641px) {
    .{component-name}__content {
      flex-direction: row;
      gap: var(--spacing-4);
    }
  }
}
```

### Fallback Notes
- {Describe any visual differences between CQ and fallback versions}
- {Note if fallback is pixel-perfect or approximate}
- {Target browser matrix: Chrome 105+, Firefox 110+, Safari 16+}

## Nesting Considerations

{If this container is nested inside another container query context, describe the relationship.}

| Parent Container | This Container | Interaction |
|-----------------|----------------|-------------|
| {parent-name} | {component-name} | {How parent size affects this component's available width} |

## Testing Checklist

- [ ] Component renders correctly at each defined breakpoint
- [ ] Transitions between breakpoints are smooth (no layout jumps)
- [ ] Content does not overflow at any container width
- [ ] Fallback media queries produce acceptable layout
- [ ] Nested container queries resolve correctly
- [ ] DevTools Container Query overlay matches expected behavior
- [ ] RTL layout works at all breakpoints
- [ ] Reduced motion does not affect layout transitions

## Visual Reference

| Breakpoint | Screenshot / Figma Frame |
|------------|--------------------------|
| < 300px | {link or "See Figma > Frame Name"} |
| 300-500px | {link or "See Figma > Frame Name"} |
| > 500px | {link or "See Figma > Frame Name"} |
