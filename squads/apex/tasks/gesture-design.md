# Task: gesture-design

```yaml
id: gesture-design
version: "1.0.0"
title: "Gesture Interaction Design"
description: >
  Designs gesture interaction patterns for a React Native feature.
  Maps the gesture vocabulary, designs gesture handlers using
  react-native-gesture-handler, defines gesture composition rules,
  plans haptic feedback, validates touch target sizes, and documents
  the complete gesture specification.
elicit: false
owner: mobile-eng
executor: mobile-eng
outputs:
  - Gesture vocabulary map
  - Gesture handler specifications
  - Gesture composition rules
  - Haptic feedback plan
  - Touch target validation report
  - Gesture specification document
```

---

## When This Task Runs

This task runs when:
- A new mobile feature requires touch interactions beyond basic taps
- Complex gestures need to coexist (e.g., swipe inside a scrollable list)
- Gesture conflicts are occurring (e.g., swipe-to-dismiss competing with horizontal scroll)
- A feature requires custom gesture recognition
- `*gesture-design` or `*design-gestures` is invoked

This task does NOT run when:
- The feature is web-only with mouse/keyboard interactions
- Only standard button taps are needed (no gesture design required)
- The task is about animation math, not gesture input (use `animation-architecture`)

---

## Execution Steps

### Step 1: Map Gesture Vocabulary

Define every gesture interaction the feature needs, categorized by type and intent.

| Gesture | Library Type | Intent | Example |
|---------|-------------|--------|---------|
| Tap | `TapGesture` | Select, activate | Tap a list item to open |
| Double tap | `TapGesture({ numberOfTaps: 2 })` | Quick action | Double-tap to like |
| Long press | `LongPressGesture` | Context menu, drag start | Hold to reorder |
| Swipe horizontal | `PanGesture` | Navigate, dismiss, reveal | Swipe to delete |
| Swipe vertical | `PanGesture` | Scroll, dismiss, pull-to-refresh | Pull down to refresh |
| Pinch | `PinchGesture` | Zoom | Pinch to zoom image |
| Rotation | `RotationGesture` | Rotate | Rotate a photo |
| Fling | `FlingGesture` | Quick directional action | Fling to dismiss |

For each gesture in the feature:
- Describe the user intent (what are they trying to do?)
- Define the activation threshold (how much movement before gesture activates?)
- Define the completion criteria (when is the gesture "done"?)
- Define the cancel behavior (what happens if the user changes their mind mid-gesture?)

**Output:** Complete gesture vocabulary for the feature.

### Step 2: Design Gesture Handlers

Implement gesture handlers using `react-native-gesture-handler` v2 API.

For each gesture, define:

```typescript
const panGesture = Gesture.Pan()
  .activeOffsetX([-10, 10])       // Activate after 10px horizontal movement
  .failOffsetY([-5, 5])           // Fail if vertical movement exceeds 5px first
  .minPointers(1)                  // Single finger
  .maxPointers(1)                  // Prevent multi-touch conflicts
  .onStart((event) => {
    'worklet';
    // Save starting position
  })
  .onUpdate((event) => {
    'worklet';
    // Update shared values based on translation
  })
  .onEnd((event) => {
    'worklet';
    // Determine if gesture completed (velocity/distance threshold)
    // Animate to final position or snap back
  });
```

Key configuration for each handler:
- **Activation offsets:** When the gesture becomes active
- **Fail offsets:** When the gesture should fail (to let another gesture win)
- **Min/max distance:** For swipe completion detection
- **Velocity thresholds:** For fling detection
- **Hit slop:** Additional activation area around the element

**Output:** Configured gesture handlers for each interaction.

### Step 3: Define Gesture Composition

Design how multiple gestures coexist when they could conflict.

**Composition types:**

| Type | API | Use When |
|------|-----|----------|
| Simultaneous | `Gesture.Simultaneous(pinch, rotation)` | Both should work at the same time |
| Exclusive | `Gesture.Exclusive(longPress, tap)` | Only one should activate |
| Race | `Gesture.Race(swipeLeft, swipeRight)` | First to activate wins |

**Common conflict resolutions:**

- **Horizontal swipe inside ScrollView:** Set `failOffsetY` on swipe so vertical scroll wins when user scrolls vertically
- **Tap vs Long Press:** Use `Gesture.Exclusive(longPress, tap)` — long press takes priority, tap fires only if long press fails
- **Pinch + Pan (map-like):** Use `Gesture.Simultaneous(pinch, pan)` with `minPointers(2)` on pinch
- **Swipe-to-delete inside horizontal pager:** Use `activeOffsetX` with a higher threshold on swipe than the pager

```typescript
const composed = Gesture.Exclusive(
  longPressGesture,  // Higher priority — checked first
  tapGesture         // Only activates if long press fails
);
```

Test each composition by:
1. Executing the primary gesture — does it work?
2. Executing the secondary gesture — does it work?
3. Starting one gesture and switching to the other — does it resolve correctly?
4. Rapid alternation between gestures — any stuck states?

**Output:** Gesture composition rules with conflict resolution strategy.

### Step 4: Plan Haptic Feedback

Design haptic feedback to reinforce gesture interactions with physical sensation.

**iOS Haptic Types (UIFeedbackGenerator):**
| Type | When to Use | Example |
|------|-------------|---------|
| `impact(light)` | Subtle acknowledgment | Item snaps to position |
| `impact(medium)` | Standard action feedback | Toggle switch |
| `impact(heavy)` | Significant action | Delete confirmation |
| `selection` | Selection change | Scrolling through picker |
| `notification(success)` | Positive outcome | Payment successful |
| `notification(warning)` | Cautionary | Approaching limit |
| `notification(error)` | Error | Action failed |

**Android Haptic Equivalents:**
- Use `ReactNativeHapticFeedback` or `expo-haptics`
- Map iOS types to Android vibration patterns
- Test on multiple Android devices (haptic quality varies widely)

**Haptic timing rules:**
- Fire haptics at gesture state changes (activation, threshold crossing, completion)
- Never fire haptics continuously during gesture (it feels like vibration, not feedback)
- Fire BEFORE visual feedback, not after (anticipation > confirmation)
- Respect system haptic settings (some users disable haptics)

**Output:** Haptic feedback map for each gesture event.

### Step 5: Validate Touch Target Sizes

Verify that all interactive elements meet minimum touch target requirements.

**Minimum requirements:**
- **Apple HIG:** 44x44 points minimum
- **Material Design:** 48x48 dp minimum
- **WCAG 2.5.8:** 24x24 CSS pixels minimum (Level AAA: 44x44)

For each interactive element:
- Measure the visual size
- Measure the effective touch area (including `hitSlop`)
- If the visual element is smaller than 44x44, add `hitSlop` to expand the touch area
- Verify that expanded touch areas do not overlap with adjacent targets

```typescript
<Pressable
  hitSlop={{ top: 8, bottom: 8, left: 8, right: 8 }}
  style={{ width: 32, height: 32 }}
  // Effective touch area: 48x48 ✓
>
```

Check spacing between adjacent targets:
- Minimum 8pt spacing between touch targets
- If targets are closer, ensure only one responds to a tap at the boundary

**Output:** Touch target audit with pass/fail for each interactive element.

### Step 6: Document Gesture Specifications

Compile the complete gesture specification for the feature.

Documentation includes:
- Gesture vocabulary table (from Step 1)
- Handler configurations (from Step 2)
- Composition rules (from Step 3)
- Haptic feedback map (from Step 4)
- Touch target sizes (from Step 5)
- Visual diagrams showing gesture areas on the UI
- Platform-specific notes (iOS vs Android differences)

**Output:** Complete gesture specification document.

---

## Quality Criteria

- Every gesture must have defined activation, update, and end behavior
- Gesture compositions must handle all conflict scenarios
- All touch targets must meet 44x44 point minimum
- Haptic feedback must be mapped to specific gesture events
- Specification must cover both iOS and Android behavior

---

*Squad Apex — Gesture Interaction Design Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-gesture-design
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Every gesture must have defined activation, update, and end behavior"
    - "Gesture compositions must handle all conflict scenarios"
    - "All touch targets must meet 44x44 point minimum (with hitSlop if needed)"
    - "Haptic feedback must be mapped to specific gesture events"
    - "Specification must cover both iOS and Android behavior"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@motion-eng` or `@qa-xplatform` |
| Artifact | Complete gesture specification with vocabulary, handler configs, composition rules, and haptic plan |
| Next action | Implement animation responses for gestures via `@motion-eng` or validate with `gesture-test-suite` via `@qa-xplatform` |
