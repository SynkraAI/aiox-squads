# Task: scene-architecture

```yaml
id: scene-architecture
version: "1.0.0"
title: "3D Scene Architecture"
description: >
  Designs the 3D scene architecture for a spatial or immersive feature.
  Defines the scene graph hierarchy, chooses the rendering approach
  using React Three Fiber (R3F), plans asset loading strategy,
  designs the interaction model, sets up camera and lighting, and
  establishes a performance budget for 3D rendering.
elicit: false
owner: spatial-eng
executor: spatial-eng
outputs:
  - Scene graph hierarchy design
  - Rendering approach specification
  - Asset loading strategy
  - Interaction model definition
  - Camera and lighting setup
  - 3D performance budget
```

---

## When This Task Runs

This task runs when:
- A new 3D or spatial feature needs to be designed from scratch
- An existing 3D scene needs architectural restructuring
- A WebXR or VisionOS experience is being planned
- The team needs to decide how to structure a complex 3D environment
- `*scene-arch` or `*3d-architecture` is invoked

This task does NOT run when:
- Only a shader needs to be written (use `shader-design`)
- Only performance optimization is needed (use `3d-performance-audit`)
- The task is about 2D animation (delegate to `@motion-eng`)

---

## Execution Steps

### Step 1: Define Scene Graph Hierarchy

Design the hierarchical structure of the 3D scene using a declarative component tree.

```tsx
<Canvas>
  <SceneRoot>
    <EnvironmentGroup>
      <Lighting />
      <Skybox />
      <Ground />
    </EnvironmentGroup>

    <ContentGroup>
      <PrimaryObject />
      <SecondaryObjects>
        <ObjectA position={[1, 0, 0]} />
        <ObjectB position={[-1, 0, 0]} />
      </SecondaryObjects>
    </ContentGroup>

    <InteractionGroup>
      <Cursor />
      <SelectionHighlight />
      <GizmoControls />
    </InteractionGroup>

    <UIOverlayGroup>
      <HUD />
      <Tooltips />
    </UIOverlayGroup>

    <CameraRig>
      <PerspectiveCamera />
      <OrbitControls />
    </CameraRig>
  </SceneRoot>
</Canvas>
```

Scene graph design principles:
- Group objects by purpose (environment, content, interaction, UI)
- Use scene groups for batch operations (visibility toggle, transform inheritance)
- Keep the hierarchy shallow where possible (deep nesting complicates transforms)
- Separate static geometry from dynamic geometry for rendering optimization
- Plan for instancing: repeated objects should use `<Instances>` instead of duplicated meshes

**Output:** Scene graph hierarchy diagram.

### Step 2: Choose Rendering Approach

Select the rendering strategy based on the feature requirements.

**React Three Fiber (R3F) — Declarative (preferred):**
- React components map directly to Three.js objects
- Reactive: scene updates when state changes
- Composable: use React patterns (hooks, context, suspense)
- Best for: UI-driven 3D, data visualization, interactive experiences

```tsx
function Scene() {
  const [hovered, setHovered] = useState(false);
  return (
    <mesh
      onPointerOver={() => setHovered(true)}
      onPointerOut={() => setHovered(false)}
      scale={hovered ? 1.2 : 1}
    >
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color={hovered ? 'hotpink' : 'orange'} />
    </mesh>
  );
}
```

**drei helpers — High-level abstractions:**
- Pre-built components: `<Environment>`, `<OrbitControls>`, `<Text3D>`, `<Html>`
- Performance utilities: `<Instances>`, `<Merged>`, `<LOD>`
- Staging: `<Stage>`, `<ContactShadows>`, `<AccumulativeShadows>`
- Use drei for common patterns instead of building from scratch

**Imperative (escape hatch):**
- Use `useFrame` for per-frame updates that need raw Three.js access
- Use `useThree` to access the renderer, camera, scene directly
- Only for performance-critical paths that cannot be expressed declaratively

**WebGPU consideration:**
- Three.js r160+ supports WebGPU renderer
- Decision: WebGL (broad compatibility) vs WebGPU (better performance, limited browser support)
- For production: WebGL with WebGPU as progressive enhancement

**Output:** Rendering approach selection with rationale.

### Step 3: Plan Asset Loading Strategy

Design how 3D assets (models, textures, HDRIs, fonts) are loaded and managed.

**Asset types and formats:**
| Asset Type | Format | Loader | Size Guideline |
|-----------|--------|--------|----------------|
| 3D Models | glTF/GLB | `useGLTF` (drei) | < 5MB per model |
| Textures | WebP, KTX2, Basis | `useTexture` (drei) | < 2MB per texture |
| HDR Environment | HDR, EXR | `useEnvironment` (drei) | < 3MB |
| 3D Text/Fonts | WOFF/TTF | `useFont` (drei) | < 500KB |

Loading strategy:
```tsx
// Preload critical assets
useGLTF.preload('/models/hero-object.glb');

// Lazy load with Suspense
function Scene() {
  return (
    <Suspense fallback={<LoadingPlaceholder />}>
      <HeroObject />
      <Suspense fallback={null}>
        <SecondaryAssets /> {/* Load after hero */}
      </Suspense>
    </Suspense>
  );
}
```

Asset optimization:
- Compress GLB files with `gltf-transform` or `meshoptimizer`
- Use Draco compression for geometry
- Use KTX2/Basis Universal for GPU-compressed textures
- Implement LOD (Level of Detail) for complex models
- Use texture atlases for multiple small textures

**Output:** Asset loading strategy with format and size guidelines.

### Step 4: Design Interaction Model

Define how users interact with the 3D scene.

**Interaction modes:**

| Mode | Input | R3F API | Use Case |
|------|-------|---------|----------|
| Mouse/Touch | Click, hover, drag | `onPointerDown`, `onPointerOver`, `onPointerMove` | Web desktop/mobile |
| Gaze | Look at target for duration | Custom raycaster + timer | VR headset |
| Hand tracking | Pinch, grab, poke | WebXR Hand API | VR/AR headset |
| Controller | Trigger, grip, thumbstick | WebXR Controller API | VR headset |

R3F pointer events:
```tsx
<mesh
  onClick={(e) => { e.stopPropagation(); select(e.object); }}
  onPointerOver={(e) => { document.body.style.cursor = 'pointer'; }}
  onPointerOut={(e) => { document.body.style.cursor = 'default'; }}
  onPointerMissed={() => { deselect(); }}
>
```

Interaction design rules:
- Every interactive object must have visual feedback (hover state, selection highlight)
- Click/tap targets must be large enough (minimum 48px equivalent in screen space)
- Support both mouse and touch on web
- Raycasting performance: limit raycast targets using `layers` or groups
- Use `meshBounds` from drei for faster bounding-box raycasting on complex geometry

**Output:** Interaction model specification with input mappings.

### Step 5: Set Up Camera and Lighting

Configure the camera system and lighting environment.

**Camera setup:**
```tsx
<PerspectiveCamera
  makeDefault
  fov={45}            // Field of view (45-75 typical)
  near={0.1}          // Near clipping plane
  far={1000}          // Far clipping plane
  position={[0, 2, 5]} // Initial position
/>
<OrbitControls
  enableDamping
  dampingFactor={0.05}
  minDistance={2}
  maxDistance={20}
  maxPolarAngle={Math.PI / 2} // Prevent looking below ground
/>
```

**Lighting setup:**
```tsx
<ambientLight intensity={0.3} />
<directionalLight
  position={[10, 10, 5]}
  intensity={1}
  castShadow
  shadow-mapSize={[2048, 2048]}
  shadow-camera-far={50}
/>
<Environment preset="city" /> {/* HDR environment for reflections */}
```

Lighting design principles:
- Use environment maps for realistic reflections (PBR materials)
- Limit shadow-casting lights (expensive — typically 1-2 max)
- Use baked lighting for static environments
- Use `AccumulativeShadows` from drei for soft contact shadows
- Test with both light and dark environment presets

**Output:** Camera and lighting configuration.

### Step 6: Define 3D Performance Budget

Establish performance constraints for the 3D scene.

| Metric | Budget | Measurement |
|--------|--------|-------------|
| Frame rate | 60fps (desktop), 30fps (mobile VR) | `useFrame` + Stats component |
| Draw calls | < 100 per frame | Three.js renderer info |
| Triangle count | < 500K (desktop), < 100K (mobile) | `renderer.info.render.triangles` |
| Texture memory | < 256MB (desktop), < 64MB (mobile) | `renderer.info.memory.textures` |
| Scene load time | < 3 seconds (hero), < 8 seconds (full) | Performance API |
| Total asset size | < 20MB (all assets) | Bundle analysis |

Performance monitoring:
```tsx
import { Stats } from '@react-three/drei';

function Scene() {
  return (
    <Canvas>
      {process.env.NODE_ENV === 'development' && <Stats />}
      {/* ... scene content ... */}
    </Canvas>
  );
}
```

Budget enforcement:
- Add budget checks to CI/CD pipeline
- Warn when approaching 80% of budget
- Block when exceeding budget
- Track budgets per page/route, not just globally

**Output:** Performance budget document with measurement strategies.

---

## Quality Criteria

- The scene graph must be organized by purpose (environment, content, interaction, UI)
- Asset loading must use Suspense boundaries with meaningful fallbacks
- Interactive objects must have visual hover/selection feedback
- The performance budget must be defined before implementation begins
- Camera controls must have sensible limits (no flying through the ground)

---

*Squad Apex — 3D Scene Architecture Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-scene-architecture
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Scene graph must be organized by purpose (environment, content, interaction, UI)"
    - "Asset loading must use Suspense boundaries with meaningful fallbacks"
    - "Interactive objects must have visual hover/selection feedback defined"
    - "3D performance budget must be defined with specific metrics (FPS, draw calls, triangle count)"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@motion-eng` or `@apex-lead` |
| Artifact | Scene graph hierarchy, rendering approach specification, asset loading strategy, interaction model, camera/lighting setup, and 3D performance budget |
| Next action | Route to `@motion-eng` for animation integration or to `@spatial-eng` for `shader-design` implementation |
