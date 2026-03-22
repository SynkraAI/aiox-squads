# Component: {ComponentName}

**Status:** Experimental | Alpha | Beta | Stable
**Owner:** @design-sys-eng (Diana)
**Package:** packages/ui/{category}/{component-name}/

## API

### Props
| Prop | Type | Default | Description |
|------|------|---------|-------------|
| variant | 'primary' \| 'secondary' \| 'ghost' | 'primary' | Visual variant |
| size | 'sm' \| 'md' \| 'lg' | 'md' | Size variant |

### Tokens Used
| Token | Value (Light) | Value (Dark) |
|-------|--------------|-------------|
| {component}-bg | | |
| {component}-text | | |

## Variants
{Visual examples for each variant}

## States
- [ ] Default
- [ ] Hover
- [ ] Focus
- [ ] Active
- [ ] Disabled
- [ ] Loading
- [ ] Error

## Responsive Behavior
| Viewport | Behavior |
|----------|----------|
| < 640px | |
| 640-1024px | |
| > 1024px | |

## Motion
- Enter: {spring config}
- Exit: {spring config}
- Hover: {spring config}
- Reduced motion: {fallback}

## Accessibility
- Role: {ARIA role}
- Keyboard: {key interactions}
- Screen reader: {announcements}

## Platform Variants
- Web: {any web-specific behavior}
- Mobile: {any mobile-specific behavior}
- Spatial: {any spatial-specific behavior}

## Storybook
File: `{component-name}.stories.tsx`
