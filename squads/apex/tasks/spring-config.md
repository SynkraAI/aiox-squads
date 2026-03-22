# Task: spring-config

```yaml
id: spring-config
version: "1.0.0"
title: "Spring Physics Configuration"
description: >
  Designs spring physics configurations for animations, selecting
  the right stiffness, damping, and mass values to match the
  interaction energy level. Tests feel on real devices, verifies
  60fps performance, and documents configurations with design
  rationale.
elicit: false
owner: motion-eng
executor: motion-eng
outputs:
  - Interaction energy level classification
  - Spring parameter selection (stiffness/damping/mass)
  - Real device feel test results
  - 60fps verification
  - Documented configuration with rationale
```

---

## When This Task Runs

This task runs when:
- A new animation needs spring physics tuning
- An existing spring animation does not feel right (too bouncy, too stiff, too slow)
- A motion language is being established for the design system
- Spring parameters need to be standardized across the product
- `*spring-config` or `*tune-spring` is invoked

This task does NOT run when:
- The animation does not use springs (though it probably should)
- A full animation design is needed (use `animation-design`)
- A full motion audit is needed (use `motion-audit`)

---

## Execution Steps

### Step 1: Define Interaction Energy Level

Classify the interaction by its energy level — this determines the spring character.

| Energy Level | Description | Example Interactions |
|-------------|-------------|---------------------|
| **Calm** | Low energy, passive, ambient | Background parallax, idle state, subtle breathing |
| **Gentle** | Low-medium energy, welcoming | Page enter, card reveal, drawer slide |
| **Responsive** | Medium energy, reactive | Button feedback, toggle, menu open |
| **Snappy** | Medium-high energy, decisive | Tab switch, chip select, quick dismiss |
| **Energetic** | High energy, celebratory | Success animation, confetti, bounce in |
| **Urgent** | Maximum energy, attention-grabbing | Error shake, notification pop, alert |

Ask:
- What emotion should this interaction convey? (Calm → Urgent spectrum)
- How important is this action to the user? (Low importance = calm, high importance = snappy)
- Is this a primary action or background decoration? (Primary = responsive+, background = calm)
- How frequently does this animation play? (Frequent = calmer to avoid fatigue, rare = can be more energetic)

**Output:** Energy level classification with rationale.

### Step 2: Select Base Spring Configuration

Map the energy level to a starting spring configuration.

**Spring parameter reference:**

| Parameter | What It Controls | Higher Value | Lower Value |
|-----------|-----------------|--------------|-------------|
| **stiffness** | How quickly the spring moves toward target | Faster, more responsive | Slower, more relaxed |
| **damping** | How quickly oscillation stops | Less bounce, quicker settle | More bounce, longer settle |
| **mass** | Inertia of the animated object | Slower start, heavier feel | Quicker start, lighter feel |

**Base configurations by energy level:**

```typescript
const springPresets = {
  calm: { stiffness: 80, damping: 15, mass: 1.2 },
  gentle: { stiffness: 120, damping: 14, mass: 1.0 },
  responsive: { stiffness: 200, damping: 20, mass: 1.0 },
  snappy: { stiffness: 300, damping: 25, mass: 0.8 },
  energetic: { stiffness: 400, damping: 10, mass: 0.8 },
  urgent: { stiffness: 500, damping: 30, mass: 0.6 },
};
```

**Damping ratio guide:**
- `damping ratio < 1` — underdamped (oscillates before settling — bouncy)
- `damping ratio = 1` — critically damped (fastest to settle without oscillation)
- `damping ratio > 1` — overdamped (slow to settle, no oscillation — sluggish)

Formula: `dampingRatio = damping / (2 * Math.sqrt(stiffness * mass))`

For most UI animations, target a damping ratio between 0.6 and 0.9 (slightly underdamped — a tiny bit of overshoot feels natural).

**Output:** Base spring configuration selected from presets.

### Step 3: Fine-Tune Stiffness, Damping, and Mass

Adjust the base configuration for the specific animation context.

**Tuning workflow:**
1. Start with the base preset from Step 2
2. Adjust stiffness first (speed of response)
3. Adjust damping second (amount of overshoot)
4. Adjust mass last (rarely needed, only for heavy/light feel)

**Stiffness tuning:**
- If animation feels too slow → increase stiffness by 50
- If animation feels too fast/aggressive → decrease stiffness by 50
- Keep stiffness between 50 (very slow) and 600 (very fast)

**Damping tuning:**
- If too much bounce → increase damping by 5
- If no character (feels dead) → decrease damping by 5
- Keep damping between 5 (very bouncy) and 40 (no bounce)

**Mass tuning:**
- If it should feel heavy (like dragging furniture) → increase mass to 1.5-2.0
- If it should feel light (like a notification) → decrease mass to 0.5-0.8
- Default mass of 1.0 is correct for most UI elements

**Interactive testing:**
```tsx
// Use Framer Motion DevTools or a custom spring playground
function SpringPlayground() {
  const [config, setConfig] = useState({ stiffness: 200, damping: 20, mass: 1 });
  return (
    <div>
      <input type="range" min={50} max={600} value={config.stiffness}
        onChange={(e) => setConfig(c => ({ ...c, stiffness: +e.target.value }))} />
      <motion.div
        animate={{ x: toggled ? 200 : 0 }}
        transition={{ type: "spring", ...config }}
      />
    </div>
  );
}
```

**Output:** Fine-tuned spring configuration.

### Step 4: Test Feel on Real Device

Spring physics feel different on a real device versus a development monitor. Test on actual hardware.

**Testing protocol:**
1. Run the animation on the target device (phone, tablet, laptop)
2. Interact with it naturally (do not just watch — trigger it with a tap/click)
3. Trigger it repeatedly (10+ times) — does it feel consistent and satisfying each time?
4. Trigger it while distracted (not looking directly) — does it still feel right peripherally?
5. Ask someone unfamiliar with the project to interact — observe their reaction

**What to evaluate:**
- **Responsiveness:** Does the animation start immediately on interaction? (No perceived delay)
- **Momentum:** Does the motion feel like it has physical weight? (Not floaty, not jerky)
- **Settlement:** Does the animation come to rest cleanly? (No visible micro-oscillation at the end)
- **Interruption:** If triggered again mid-animation, does it respond naturally? (Springs handle this well)
- **Consistency:** Does it feel the same every time? (Springs are deterministic, so yes)

**Device testing:**
- Test on the slowest target device (performance affects perceived feel)
- Test with and without low power mode
- Test in portrait and landscape (if applicable)

**Output:** Real device feel test results.

### Step 5: Verify 60fps

Confirm the spring animation maintains 60fps throughout its duration.

**Measurement:**
- Use Chrome DevTools Performance tab → Record during animation
- Check frame timing: every frame should be <= 16.67ms
- Look for dropped frames (gaps in the frame timeline)

**Common spring fps issues:**
- Very low damping with high stiffness creates many oscillation frames (animation runs longer = more frames to render)
- Animating layout properties (width, height) with springs causes layout thrashing
- Multiple spring animations running simultaneously on complex DOM

**Solutions:**
- Use `will-change: transform` on animated elements
- Animate only transform and opacity
- If multiple springs run together, ensure they do not all update different layout properties
- Consider `layout` prop in Framer Motion for layout animations (automatically uses FLIP technique)

**Output:** 60fps verification with frame timing data.

### Step 6: Document Configuration with Rationale

Record the final spring configuration for reuse and team understanding.

```typescript
/**
 * Spring: Modal Enter
 * Energy: Gentle
 * Intent: Welcome the user to new content without startling
 *
 * Stiffness 150: Slightly slower than responsive — modal should
 *   feel like it's floating in, not snapping in
 * Damping 18: Slight overshoot (ratio ~0.73) — gives a sense
 *   of physical depth without feeling bouncy
 * Mass 1.0: Default weight — modal is a standard-sized element
 *
 * Settle time: ~400ms
 * Peak overshoot: ~3% scale
 */
export const modalEnterSpring = {
  type: "spring" as const,
  stiffness: 150,
  damping: 18,
  mass: 1.0,
};
```

Document:
- The energy level and intent
- Why each parameter value was chosen
- Approximate settle time
- Approximate peak overshoot percentage
- Which components use this configuration
- When to reuse this config vs. create a new one

**Output:** Documented spring configuration added to the motion token library.

---

## Quality Criteria

- Spring configuration must match the declared energy level
- Damping ratio must be between 0.6 and 0.9 for standard UI animations
- Animation must maintain 60fps on target devices
- Configuration must be tested on a real device, not just a monitor
- Documentation must explain WHY each value was chosen

---

*Squad Apex — Spring Physics Configuration Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-spring-config
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Spring configuration must match the declared energy level"
    - "Damping ratio must be between 0.6 and 0.9 for standard UI animations"
    - "Animation must maintain 60fps on target devices with frame timing data"
    - "Configuration must be tested on a real device, not just a monitor"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@mobile-eng` or `@react-eng` |
| Artifact | Interaction energy level classification, spring parameter selection, real device test results, 60fps verification, and documented configuration with design rationale |
| Next action | Integrate spring configuration into component animations via `@mobile-eng` or `@react-eng` |
