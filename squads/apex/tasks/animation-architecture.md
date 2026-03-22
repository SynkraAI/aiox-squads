# Task: animation-architecture

```yaml
id: animation-architecture
version: "1.0.0"
title: "React Native Animation Architecture"
description: >
  Designs the animation architecture for a React Native feature,
  choosing the right animation driver (Reanimated 3 vs Animated API),
  defining shared value structures, planning worklet functions,
  integrating gesture handlers, and verifying 60fps performance
  on both iOS and Android.
elicit: false
owner: mobile-eng
executor: mobile-eng
outputs:
  - Animation driver selection with rationale
  - Shared value structure definition
  - Worklet function specifications
  - Gesture handler integration plan
  - 60fps verification on both platforms
```

---

## When This Task Runs

This task runs when:
- A mobile feature requires animations beyond simple opacity/translate transitions
- Gesture-driven animations need to be designed (drag, swipe, pinch)
- An existing animation stutters or drops frames
- A complex animation sequence needs to be orchestrated
- `*animation-arch` or `*rn-animation` is invoked

This task does NOT run when:
- The animation is web-only (delegate to `@motion-eng` for Framer Motion)
- The task is about CSS transitions or keyframes (delegate to `@css-eng`)
- The animation is a simple enter/exit that can be handled by layout animations alone

---

## Execution Steps

### Step 1: Choose Animation Driver

Select the appropriate animation driver based on the animation requirements.

**Reanimated 3 (preferred for most cases):**
- Runs on the UI thread via worklets — no JS thread bridge latency
- Required for: gesture-driven animations, spring physics, complex sequences
- Supports shared values that update without re-rendering React
- Direct integration with `react-native-gesture-handler`
- Layout animations (`entering`, `exiting`, `layout` props)

**React Native Animated API (legacy, specific cases):**
- Runs on the native driver when `useNativeDriver: true`
- Acceptable for: simple opacity/translate animations without gestures
- Cannot animate layout properties (width, height, padding) on native driver
- No worklet support — limited to declarative animation configs

**When to choose Reanimated 3:**
- Any gesture-connected animation
- Animations that need to respond to scroll position
- Spring physics with configurable stiffness/damping
- Animations that involve layout properties
- Complex sequences with dependent timing

**When Animated API is acceptable:**
- Simple fade-in/fade-out
- Basic translate animations
- No gesture interaction needed
- Project does not yet have Reanimated installed and animation needs are minimal

**Output:** Selected driver with rationale.

### Step 2: Define Shared Value Structure

Design the shared values that will drive the animations. Shared values are the bridge between gestures, animations, and the rendered UI.

```typescript
// Example shared value structure for a swipeable card
const translateX = useSharedValue(0);
const translateY = useSharedValue(0);
const scale = useSharedValue(1);
const rotation = useSharedValue(0);
const opacity = useSharedValue(1);
const cardContext = useSharedValue({ startX: 0, startY: 0 });
```

For each shared value:
- **Name:** Clear, descriptive name
- **Initial value:** Starting state
- **Range:** Minimum and maximum expected values
- **Driven by:** What updates this value (gesture, timing animation, spring, derived)
- **Consumed by:** Which animated style uses this value

Map the data flow:
```
Gesture → shared value → derived value → animated style → rendered view
```

Identify derived animated values (values computed from other shared values):
```typescript
const cardRotation = useDerivedValue(() => {
  return interpolate(translateX.value, [-200, 0, 200], [-15, 0, 15]);
});
```

**Output:** Shared value inventory with data flow diagram.

### Step 3: Plan Worklet Functions

Design the worklet functions that will run on the UI thread.

Worklet rules:
- Worklets run on the UI thread — they CANNOT access React state or JS thread variables
- All data must come through shared values or be passed as worklet arguments
- No console.log, fetch, or any JS thread API inside worklets
- Use `runOnJS()` to call back to JS thread when needed (e.g., triggering haptics, updating state)

Plan worklets for:
- **Gesture handlers:** `onBegin`, `onUpdate`, `onEnd` worklets
- **Animation callbacks:** `withTiming`, `withSpring`, `withDecay` callbacks
- **Derived computations:** `useDerivedValue` worklets for interpolation
- **Conditional logic:** Threshold checks, snap points, boundary clamping

```typescript
const gestureHandler = useAnimatedGestureHandler({
  onStart: (_, ctx) => {
    'worklet';
    ctx.startX = translateX.value;
  },
  onActive: (event, ctx) => {
    'worklet';
    translateX.value = ctx.startX + event.translationX;
  },
  onEnd: (event) => {
    'worklet';
    if (Math.abs(event.velocityX) > 500) {
      translateX.value = withSpring(event.velocityX > 0 ? 300 : -300);
      runOnJS(onSwipeComplete)(event.velocityX > 0 ? 'right' : 'left');
    } else {
      translateX.value = withSpring(0);
    }
  },
});
```

**Output:** Worklet function specifications with thread safety notes.

### Step 4: Design Gesture Handler Integration

Plan how gesture handlers connect to the animation system.

- Select gesture types from `react-native-gesture-handler`:
  - `PanGesture` — drag, swipe
  - `PinchGesture` — zoom
  - `RotationGesture` — rotate
  - `TapGesture` — tap, double-tap
  - `LongPressGesture` — long press
  - `FlingGesture` — directional fling

- Design gesture composition:
  - `Gesture.Simultaneous()` — both gestures active at once (e.g., pinch + rotation)
  - `Gesture.Exclusive()` — only one gesture wins (e.g., tap vs. long press)
  - `Gesture.Race()` — first gesture to activate wins

- Configure gesture properties:
  - `minDistance` — activation threshold for pan
  - `minPointers` / `maxPointers` — touch count requirements
  - `failOffsetX/Y` — when to fail the gesture
  - `activeOffsetX/Y` — when to activate the gesture

- Map gestures to shared values:
  ```
  PanGesture.onUpdate → translateX, translateY
  PinchGesture.onUpdate → scale
  RotationGesture.onUpdate → rotation
  ```

**Output:** Gesture handler configuration with composition rules.

### Step 5: Test on Both iOS and Android

Verify the animation implementation works correctly on both platforms.

**iOS testing:**
- Test on iPhone SE (smallest screen, weakest current device)
- Test on iPhone 15 Pro (latest, reference device)
- Verify gesture responsiveness with iOS-specific touch handling
- Check for any Core Animation layer issues

**Android testing:**
- Test on a mid-range Android device (not just flagship)
- Verify that Reanimated worklets execute on the UI thread (not falling back to JS)
- Check for Android-specific gesture conflicts (back gesture, pull-to-refresh)
- Test with Hermes engine (default in RN 0.70+)

**Cross-platform checks:**
- Gesture activation thresholds may need platform-specific tuning
- Spring physics should feel natural on both platforms
- Animation cancellation and interruption behavior
- Memory usage during long-running animations

**Output:** Platform test results with any platform-specific adjustments.

### Step 6: Verify 60fps

Profile the animation to confirm it maintains 60fps (16.67ms per frame) throughout.

**Profiling tools:**
- React Native Performance Monitor (shake menu → Show Perf Monitor)
- Flipper performance plugin
- Xcode Instruments (iOS) — Core Animation FPS
- Android Studio Profiler — frame rendering time

**What to measure:**
- Frame rate during gesture interaction (must stay at 60fps)
- Frame rate during spring/timing animations
- JS thread frame rate (should be irrelevant if worklets are on UI thread)
- UI thread frame rate (this is the critical metric)
- Memory allocation during animation (watch for garbage collection pauses)

**Common 60fps killers:**
- Shared value updates triggering React re-renders (fix: use `useAnimatedStyle`, not inline styles)
- Heavy `useDerivedValue` computations
- `runOnJS` called too frequently (batch calls)
- Large view hierarchies being animated (reduce node count)
- Shadow rendering on Android (use `elevation` carefully)

**Output:** Performance profile confirming 60fps or identifying bottlenecks to fix.

---

## Quality Criteria

- All animations must run on the UI thread (no JS thread bridge for gesture-driven animations)
- 60fps must be maintained on a mid-range device, not just flagship
- Worklets must not access JS thread APIs without `runOnJS`
- Gesture composition must handle edge cases (simultaneous touches, rapid gestures)
- Both iOS and Android must be tested — not just one platform

---

*Squad Apex — Animation Architecture Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-animation-architecture
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Animation driver selection must include rationale comparing Reanimated 3 vs Animated API"
    - "Shared value structure must be defined with TypeScript types"
    - "Gesture handler integration plan must cover both iOS and Android"
    - "60fps verification must be demonstrated on both platforms with profiling evidence"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@motion-eng` |
| Artifact | Animation architecture specification with driver selection, shared values, and worklet specs |
| Next action | Implement animation sequences and spring configurations using the defined architecture |
