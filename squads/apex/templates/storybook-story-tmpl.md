# Storybook Story: {ComponentName}

**Date:** {YYYY-MM-DD}
**Author:** @design-sys-eng (Diana)
**Component Package:** `packages/ui/src/components/{ComponentName}/`
**Story File:** `{ComponentName}.stories.tsx`

## Component Name

{ComponentName} — {brief description}

## Import Statements

```tsx
import type { Meta, StoryObj } from '@storybook/react';
import { {ComponentName} } from './{ComponentName}';
// import { within, userEvent, expect } from '@storybook/test';
// import { ThemeDecorator } from '../../decorators/ThemeDecorator';
```

## Meta Configuration

```tsx
const meta: Meta<typeof {ComponentName}> = {
  title: 'Components/{Category}/{ComponentName}',
  component: {ComponentName},
  tags: ['autodocs'],
  parameters: {
    layout: '{centered | fullscreen | padded}',
    docs: {
      description: {
        component: '{Component description for docs page}',
      },
    },
    chromatic: {
      viewports: [320, 768, 1440],
    },
  },
  argTypes: {
    variant: {
      control: 'select',
      options: ['{primary}', '{secondary}', '{ghost}'],
      description: '{Visual variant of the component}',
    },
    size: {
      control: 'select',
      options: ['{sm}', '{md}', '{lg}'],
      description: '{Size variant}',
    },
    disabled: {
      control: 'boolean',
      description: '{Whether the component is disabled}',
    },
    // {Add additional argTypes for all public props}
  },
};

export default meta;
type Story = StoryObj<typeof {ComponentName}>;
```

## Stories

### Default
```tsx
export const Default: Story = {
  args: {
    // {Default prop values — the most common usage}
  },
};
```

### AllVariants
```tsx
export const AllVariants: Story = {
  render: () => (
    <div style={{ display: 'flex', flexWrap: 'wrap', gap: '1rem' }}>
      {/* Render each variant side by side */}
      <{ComponentName} variant="primary">{label}</{ComponentName}>
      <{ComponentName} variant="secondary">{label}</{ComponentName}>
      <{ComponentName} variant="ghost">{label}</{ComponentName}>
    </div>
  ),
  parameters: {
    docs: { description: { story: 'All visual variants displayed together.' } },
  },
};
```

### AllSizes
```tsx
export const AllSizes: Story = {
  render: () => (
    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
      <{ComponentName} size="sm">{label}</{ComponentName}>
      <{ComponentName} size="md">{label}</{ComponentName}>
      <{ComponentName} size="lg">{label}</{ComponentName}>
    </div>
  ),
  parameters: {
    docs: { description: { story: 'All size variants displayed together.' } },
  },
};
```

### DarkMode
```tsx
export const DarkMode: Story = {
  args: { ...Default.args },
  decorators: [ThemeDecorator('dark')],
  parameters: {
    backgrounds: { default: 'dark' },
    docs: { description: { story: 'Component rendered in dark mode.' } },
  },
};
```

### HighContrast
```tsx
export const HighContrast: Story = {
  args: { ...Default.args },
  decorators: [ThemeDecorator('high-contrast')],
  parameters: {
    docs: { description: { story: 'Component rendered in high contrast mode.' } },
  },
};
```

### Interactive
```tsx
export const Interactive: Story = {
  args: { ...Default.args },
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement);

    // {Example interaction test}
    const element = canvas.getByRole('{role}');
    await userEvent.click(element);
    await expect(element).toHaveFocus();

    // {Add keyboard navigation test}
    await userEvent.tab();
    // await expect(...).toBe...

    // {Add hover test if applicable}
    await userEvent.hover(element);
    // await expect(...).toBe...
  },
  parameters: {
    docs: { description: { story: 'Interactive test — click, keyboard, hover behaviors.' } },
  },
};
```

### WithLongContent
```tsx
export const WithLongContent: Story = {
  args: {
    ...Default.args,
    children: '{A very long text string that tests overflow and wrapping behavior across multiple lines to ensure the component handles edge cases gracefully}',
  },
  parameters: {
    docs: { description: { story: 'Tests text overflow and wrapping behavior.' } },
  },
};
```

### Empty
```tsx
export const Empty: Story = {
  args: {
    ...Default.args,
    // {Props set to empty/undefined to test empty state}
  },
  parameters: {
    docs: { description: { story: 'Component with no content — empty state rendering.' } },
  },
};
```

### Loading
```tsx
export const Loading: Story = {
  args: {
    ...Default.args,
    loading: true,
  },
  parameters: {
    docs: { description: { story: 'Component in loading/skeleton state.' } },
  },
};
```

### Error
```tsx
export const Error: Story = {
  args: {
    ...Default.args,
    error: true,
    // errorMessage: '{Something went wrong}',
  },
  parameters: {
    docs: { description: { story: 'Component in error state.' } },
  },
};
```

## Documentation

### Description
{1-2 paragraphs explaining the component purpose, when to use it, and when NOT to use it.}

### Usage Guidelines
- **Do:** {correct usage pattern}
- **Do:** {another correct usage pattern}
- **Don't:** {incorrect usage — what to avoid}
- **Don't:** {another anti-pattern}

### Accessibility Notes
- Role: `{ARIA role or semantic element used}`
- Keyboard: `{Tab to focus, Enter/Space to activate}`
- Screen reader: `{What is announced, aria-label strategy}`
- Focus indicator: `{2px ring, visible on all backgrounds}`
- Contrast: `{Meets WCAG AA for all themes}`

### Related Components
- `{RelatedComponent1}` — {how it relates}
- `{RelatedComponent2}` — {how it relates}
