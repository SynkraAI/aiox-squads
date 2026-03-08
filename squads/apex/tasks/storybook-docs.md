# Task: storybook-docs

```yaml
id: storybook-docs
version: "1.0.0"
title: "Storybook Documentation"
description: >
  Create comprehensive Storybook documentation for a design system
  component. Includes the default story, variant stories covering size,
  color, and state, mode-specific stories for light/dark/high-contrast,
  full props documentation, usage guidelines, and accessibility notes.
elicit: false
owner: design-sys-eng
executor: design-sys-eng
outputs:
  - Default story file (.stories.tsx)
  - Variant stories (size, color, state)
  - Mode stories (light, dark, high-contrast)
  - MDX documentation page
  - Accessibility documentation section
```

---

## When This Task Runs

This task runs when:
- A new component needs Storybook documentation
- An existing component's Storybook stories are incomplete or outdated
- A component is being promoted to a higher maturation level and needs full stories
- A design system review flags missing documentation
- Component API changes require updated examples

This task does NOT run when:
- The component design is not yet finalized (use `design-component` first)
- The component does not exist yet (implement first, then document)
- The task is about Storybook infrastructure configuration (route to `@devops`)

---

## Story File Structure

```
components/
  Button/
    Button.tsx
    Button.stories.tsx     ← Story file
    Button.docs.mdx        ← Extended documentation (optional)
    Button.test.tsx
```

---

## Execution Steps

### Step 1: Create Default Story

Build the primary story that showcases the component:

1. Create the story file using CSF 3.0 (Component Story Format):
   ```tsx
   import type { Meta, StoryObj } from '@storybook/react';
   import { Button } from './Button';

   const meta = {
     title: 'Components/Button',
     component: Button,
     tags: ['autodocs'],
     parameters: {
       docs: {
         description: {
           component: 'Primary button component for user actions.',
         },
       },
     },
     argTypes: {
       variant: {
         control: 'select',
         options: ['primary', 'secondary', 'ghost', 'danger'],
         description: 'Visual style variant',
       },
       size: {
         control: 'select',
         options: ['sm', 'md', 'lg'],
         description: 'Button size',
       },
       disabled: {
         control: 'boolean',
         description: 'Disables the button',
       },
     },
   } satisfies Meta<typeof Button>;

   export default meta;
   type Story = StoryObj<typeof meta>;

   export const Default: Story = {
     args: {
       children: 'Button',
       variant: 'primary',
       size: 'md',
     },
   };
   ```
2. Verify the default story renders correctly
3. Ensure all `argTypes` have descriptions and appropriate controls
4. Set meaningful default `args` that showcase the primary use case

### Step 2: Add Variant Stories

Create stories for each visual variant:

1. **Size variants:**
   ```tsx
   export const Sizes: Story = {
     render: () => (
       <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
         <Button size="sm">Small</Button>
         <Button size="md">Medium</Button>
         <Button size="lg">Large</Button>
       </div>
     ),
   };
   ```

2. **Color/style variants:**
   - Create a story showing all visual variants side by side
   - Include: primary, secondary, ghost, danger, or whatever variants exist

3. **State variants:**
   ```tsx
   export const States: Story = {
     render: () => (
       <div style={{ display: 'flex', gap: '16px' }}>
         <Button>Default</Button>
         <Button disabled>Disabled</Button>
         <Button data-loading>Loading</Button>
       </div>
     ),
   };
   ```

4. **With icons, with content variations:**
   - Show the component with different content lengths
   - Show with leading/trailing icons if supported
   - Show with and without optional props

### Step 3: Add Mode Stories

Create stories that demonstrate theme mode behavior:

1. **Light mode story:**
   ```tsx
   export const LightMode: Story = {
     parameters: {
       backgrounds: { default: 'light' },
       theme: 'light',
     },
     decorators: [(Story) => (
       <div data-theme="light"><Story /></div>
     )],
   };
   ```

2. **Dark mode story:**
   ```tsx
   export const DarkMode: Story = {
     parameters: {
       backgrounds: { default: 'dark' },
       theme: 'dark',
     },
     decorators: [(Story) => (
       <div data-theme="dark"><Story /></div>
     )],
   };
   ```

3. **High-contrast mode story:**
   - Same pattern with `data-theme="high-contrast"`
   - Verify contrast ratios are visually enhanced

4. **All modes comparison:**
   ```tsx
   export const AllModes: Story = {
     render: () => (
       <div style={{ display: 'grid', gap: '24px' }}>
         {['light', 'dark', 'high-contrast', 'dark-high-contrast'].map(mode => (
           <div key={mode} data-theme={mode} style={{ padding: '16px' }}>
             <p>{mode}</p>
             <Button variant="primary">Button</Button>
           </div>
         ))}
       </div>
     ),
   };
   ```

### Step 4: Document Props and API

Create comprehensive props documentation:

1. Ensure every prop has:
   - TypeScript type (shown automatically by autodocs)
   - Default value
   - Description explaining purpose and behavior
   - Control widget for interactive exploration
2. Document complex props with examples in the description
3. Document callback props with expected function signatures
4. List CSS custom properties the component exposes:
   ```tsx
   parameters: {
     docs: {
       description: {
         component: `
           ## CSS Custom Properties
           - \`--button-radius\` — border radius override
           - \`--button-padding\` — padding override
         `,
       },
     },
   },
   ```
5. Document any `data-*` attributes used for styling hooks

### Step 5: Add Usage Guidelines

Document when and how to use the component:

1. **Do / Don't guidance:**
   - When to use this component vs alternatives
   - Correct and incorrect usage patterns
   - Content guidelines (label text length, casing)
2. **Composition patterns:**
   - How the component composes with other components
   - Slot/children usage patterns
3. **Common patterns:**
   - Form submission button
   - Navigation action
   - Destructive action with confirmation
4. Add these as an MDX page or within the story's docs parameter

### Step 6: Add Accessibility Notes

Document accessibility behavior and requirements:

1. **Keyboard behavior:**
   - How to navigate to and interact with the component via keyboard
   - Key bindings (Enter, Space, Escape, Arrow keys)
2. **Screen reader behavior:**
   - What is announced when the component receives focus
   - ARIA attributes applied and their purpose
   - Live region behavior for dynamic content
3. **Visual accessibility:**
   - Focus indicator description
   - Minimum contrast ratio compliance
   - Support for reduced motion
4. **Testing notes:**
   - How to verify accessibility in Storybook (a11y addon)
   - Known accessibility edge cases

---

## Quality Checklist

- [ ] Default story renders without errors
- [ ] All variants have stories (size, color/style, state)
- [ ] All modes have stories (light, dark, high-contrast)
- [ ] All props have descriptions and appropriate controls
- [ ] Usage guidelines are documented
- [ ] Accessibility behavior is documented
- [ ] Stories follow CSF 3.0 format
- [ ] Autodocs tag is present for automatic documentation generation

---

*Apex Squad — Storybook Documentation Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-storybook-docs
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Default story must render without errors using CSF 3.0 format"
    - "All component variants must have stories (size, color/style, state)"
    - "All theme modes must have stories (light, dark, high-contrast)"
    - "All props must have descriptions and appropriate controls in argTypes"
    - "Accessibility behavior must be documented"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` or `@qa-visual` |
| Artifact | Default story file, variant stories, mode stories, MDX documentation page, and accessibility documentation section |
| Next action | Route to `@qa-visual` for visual regression testing against documented stories or publish to design system catalog |
