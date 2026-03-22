# Task: universal-component-design

```yaml
id: universal-component-design
version: "1.0.0"
title: "Universal Component Design"
description: >
  Designs a universal component that works across web (Next.js) and
  native (React Native / Expo) platforms. Defines the shared interface,
  identifies platform-specific concerns, designs the adaptation layer
  using solito and nativewind, implements web and native variants,
  and tests parity across platforms.
elicit: false
owner: cross-plat-eng
executor: cross-plat-eng
outputs:
  - Shared component interface
  - Platform-specific concern analysis
  - Adaptation layer design (solito/nativewind)
  - Web variant implementation
  - Native variant implementation
  - Cross-platform parity test results
```

---

## When This Task Runs

This task runs when:
- A component needs to work on both web and React Native
- A feature is being built for a cross-platform monorepo (Next.js + Expo)
- An existing web-only component needs to be extended to native
- The team needs to decide how to share UI logic across platforms
- `*universal-component` or `*cross-plat-component` is invoked

This task does NOT run when:
- The component is web-only (delegate to `@react-eng` and `@css-eng`)
- The component is native-only (delegate to `@mobile-eng`)
- The task is about monorepo structure (use `monorepo-setup`)
- The task is about design tokens (use `shared-tokens-setup`)

---

## Execution Steps

### Step 1: Define Shared Interface

Create a single TypeScript interface that both web and native variants implement.

```typescript
// packages/ui/src/Button/Button.types.ts
export interface ButtonProps {
  /** Button label */
  children: React.ReactNode;
  /** Visual variant */
  variant: 'primary' | 'secondary' | 'ghost';
  /** Size preset */
  size?: 'sm' | 'md' | 'lg';
  /** Disabled state */
  disabled?: boolean;
  /** Press handler */
  onPress: () => void;
  /** Loading state */
  loading?: boolean;
  /** Accessible label (if children is not text) */
  accessibilityLabel?: string;
}
```

Interface design rules:
- Use platform-neutral naming (`onPress` not `onClick` — React Native convention that also works on web)
- Use `children: React.ReactNode` for content
- Avoid platform-specific types (`HTMLDivElement`, `ViewStyle`)
- Include accessibility props in the shared interface
- Use discriminated unions for variants

Identify props that are shared vs. platform-specific:
- **Shared:** `variant`, `size`, `disabled`, `onPress`, `loading`, `children`
- **Web-only:** `href` (link buttons), `type` (submit/button/reset)
- **Native-only:** `hapticFeedback`, `hitSlop`

Platform-specific props should be in extension interfaces:
```typescript
export interface WebButtonProps extends ButtonProps {
  href?: string;
  type?: 'button' | 'submit' | 'reset';
}

export interface NativeButtonProps extends ButtonProps {
  hapticFeedback?: 'light' | 'medium' | 'heavy';
  hitSlop?: number;
}
```

**Output:** Shared interface with platform extension interfaces.

### Step 2: Identify Platform-Specific Concerns

Analyze the differences between web and native rendering for this component.

| Concern | Web | Native |
|---------|-----|--------|
| **Rendering** | HTML elements (`<button>`, `<div>`) | React Native components (`<Pressable>`, `<View>`) |
| **Styling** | CSS (classes, custom properties) | StyleSheet or NativeWind |
| **Touch handling** | `onClick`, `onMouseDown` | `onPress`, `onPressIn`, `onPressOut` |
| **Focus** | Built-in `:focus-visible` | Custom focus management |
| **Accessibility** | HTML semantics, `aria-*` | `accessibilityRole`, `accessibilityState` |
| **Animation** | CSS transitions, Framer Motion | Reanimated, LayoutAnimation |
| **Navigation** | `<Link href>`, `router.push` | Solito `<Link href>`, `useRouter` |
| **Text** | Any element can contain text | Must use `<Text>` component |

For each concern, decide:
- Can it be abstracted (same API, different implementation)?
- Must it be platform-specific (no meaningful abstraction)?
- Can a library handle it (NativeWind for styling, Solito for navigation)?

**Output:** Platform concern matrix with abstraction decisions.

### Step 3: Design Adaptation Layer

Design the layer that maps the shared interface to platform-specific implementations.

**Option A: NativeWind (shared Tailwind styling)**
```tsx
// Works on both web and native with NativeWind
import { styled } from 'nativewind';

const StyledPressable = styled(Pressable);

function Button({ variant, size, children, onPress }: ButtonProps) {
  return (
    <StyledPressable
      className={clsx(
        'rounded-lg items-center justify-center',
        variant === 'primary' && 'bg-blue-600',
        variant === 'secondary' && 'bg-gray-200',
        size === 'sm' && 'px-3 py-1.5',
        size === 'md' && 'px-4 py-2',
        size === 'lg' && 'px-6 py-3',
      )}
      onPress={onPress}
    >
      <Text className="text-white font-medium">{children}</Text>
    </StyledPressable>
  );
}
```

**Option B: Solito (shared navigation)**
```tsx
// packages/app/features/home/screen.tsx
import { useRouter } from 'solito/router';
import { Link } from 'solito/link';

function HomeScreen() {
  const router = useRouter();
  return (
    <Link href="/profile">
      <Text>Go to profile</Text>
    </Link>
  );
}
```

**Option C: Platform file extensions**
```
Button/
├── Button.tsx          # Shared logic, re-exports platform variant
├── Button.web.tsx      # Web-specific implementation
├── Button.native.tsx   # Native-specific implementation
├── Button.types.ts     # Shared types
└── Button.test.tsx     # Shared test behaviors
```

Choose the adaptation strategy based on:
- How different are the web and native implementations? (Similar = NativeWind, Very different = platform files)
- Does the component need navigation? (Yes = Solito)
- Is it a complex component with platform-specific behavior? (Yes = platform files)

**Output:** Adaptation layer design with selected strategy.

### Step 4: Implement Web Variant

Build the web-specific implementation.

- Use HTML semantic elements (`<button>`, `<a>`, `<input>`)
- Apply CSS via NativeWind/Tailwind or CSS modules
- Handle web-specific interactions (hover, focus-visible, keyboard)
- Integrate with Next.js features (Link, Image, router)
- Ensure SSR compatibility (no `window` access during render)

```tsx
// Button.web.tsx
'use client';
import { forwardRef } from 'react';
import type { WebButtonProps } from './Button.types';

export const Button = forwardRef<HTMLButtonElement, WebButtonProps>(
  ({ variant, size = 'md', children, onPress, href, type = 'button', ...props }, ref) => {
    if (href) {
      return (
        <Link href={href} className={getClassName(variant, size)}>
          {children}
        </Link>
      );
    }
    return (
      <button
        ref={ref}
        type={type}
        className={getClassName(variant, size)}
        onClick={onPress}
        {...props}
      >
        {children}
      </button>
    );
  }
);
```

**Output:** Web variant implementation with Next.js integration.

### Step 5: Implement Native Variant

Build the native-specific implementation.

- Use React Native components (`Pressable`, `View`, `Text`)
- Apply styles via NativeWind or StyleSheet
- Handle native-specific interactions (press states, haptics)
- Integrate with Expo Router or React Navigation via Solito
- Handle both iOS and Android differences within the native variant

```tsx
// Button.native.tsx
import { Pressable, Text } from 'react-native';
import * as Haptics from 'expo-haptics';
import type { NativeButtonProps } from './Button.types';

export function Button({
  variant,
  size = 'md',
  children,
  onPress,
  hapticFeedback,
  hitSlop = 8,
  ...props
}: NativeButtonProps) {
  const handlePress = () => {
    if (hapticFeedback) {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle[hapticFeedback]);
    }
    onPress();
  };

  return (
    <Pressable
      className={getClassName(variant, size)}
      onPress={handlePress}
      hitSlop={hitSlop}
      accessibilityRole="button"
      {...props}
    >
      {({ pressed }) => (
        <Text className={pressed ? 'opacity-70' : 'opacity-100'}>
          {children}
        </Text>
      )}
    </Pressable>
  );
}
```

**Output:** Native variant implementation with platform optimizations.

### Step 6: Test Parity Across Platforms

Verify that both variants produce equivalent user experiences.

**Functional parity:**
- Tap/click triggers onPress on both platforms
- Disabled state prevents interaction on both platforms
- Loading state shows spinner and disables interaction on both
- All variants (primary, secondary, ghost) render on both platforms

**Visual parity:**
- Colors match across platforms (using shared tokens)
- Sizes are proportionally equivalent (accounting for density differences)
- Spacing and padding are consistent
- Typography matches (font size, weight)

**Accessibility parity:**
- Both announce as "button" to assistive technology
- Both support disabled state announcement
- Both support custom accessibility labels

**Test execution:**
- Run shared test suite against both variants
- Screenshot comparison at equivalent viewport sizes
- Manual testing on real devices (web browser + iOS simulator + Android emulator)

**Output:** Parity test results with any accepted platform differences documented.

---

## Quality Criteria

- The shared interface must be implementable on both platforms without hacks
- Visual parity must be verified at comparable viewport sizes
- Both variants must pass the same accessibility checks
- Platform-specific code must be isolated to `.web.tsx` / `.native.tsx` files
- The component must work in the monorepo shared package structure

---

*Squad Apex — Universal Component Design Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-universal-component-design
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Shared interface must be implementable on both web and native without platform hacks"
    - "Visual parity must be verified at comparable viewport sizes across platforms"
    - "Both variants must pass the same accessibility checks"
    - "Platform-specific code must be isolated to .web.tsx / .native.tsx files"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@qa-xplatform` or `@apex-lead` |
| Artifact | Shared component interface, platform concern analysis, adaptation layer design, web and native variant implementations, and cross-platform parity test results |
| Next action | Route to `@qa-xplatform` for `cross-platform-test-setup` or integrate into the monorepo shared package |
