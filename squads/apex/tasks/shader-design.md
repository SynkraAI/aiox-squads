# Task: shader-design

```yaml
id: shader-design
version: "1.0.0"
title: "Custom Shader Design"
description: >
  Designs and implements custom shaders for visual effects that
  cannot be achieved with standard Three.js materials. Defines
  the visual effect requirements, selects the shader language,
  implements vertex and fragment shaders, integrates with
  React Three Fiber and drei, and tests performance impact.
elicit: false
owner: spatial-eng
executor: spatial-eng
outputs:
  - Visual effect requirements specification
  - Shader language selection
  - Vertex shader implementation
  - Fragment shader implementation
  - R3F/drei integration
  - Performance impact assessment
```

---

## When This Task Runs

This task runs when:
- A visual effect cannot be achieved with standard Three.js materials (MeshStandardMaterial, MeshPhysicalMaterial)
- Custom post-processing effects are needed
- Procedural textures or patterns are required
- Artistic/stylized rendering is needed (toon, sketch, holographic)
- `*shader-design` or `*custom-shader` is invoked

This task does NOT run when:
- Standard PBR materials can achieve the desired look
- The effect can be done with drei helpers (Sparkles, MeshTransmissionMaterial, etc.)
- The task is about scene architecture (use `scene-architecture`)
- The task is about performance (use `3d-performance-audit`)

---

## Execution Steps

### Step 1: Define Visual Effect Requirements

Clearly describe the desired visual effect with reference images, descriptions, and technical constraints.

Document:
- **Visual description:** What the effect looks like (with reference images/videos if available)
- **Trigger:** When the effect appears (always on, on hover, on state change, time-based)
- **Dynamic inputs:** What changes the effect (mouse position, time, scroll, data values)
- **Target surfaces:** What objects receive the effect (specific meshes, full screen post-process, background)
- **Performance constraint:** Frame budget for this effect (typically 2-4ms of the 16.67ms frame budget)

Example requirements:
```
Effect: Holographic shimmer on selected objects
- Rainbow color shift based on viewing angle (fresnel effect)
- Animated scan lines moving vertically
- Subtle distortion at the edges
- Must maintain 60fps on integrated GPU
- Active only on selected objects (not always-on)
```

**Output:** Visual effect specification with references and constraints.

### Step 2: Choose Shader Language

Select the appropriate shader language based on target platform and complexity.

| Language | Target | When to Use |
|----------|--------|-------------|
| **GLSL (OpenGL Shading Language)** | WebGL 1/2 | Default choice, broadest compatibility |
| **WGSL (WebGPU Shading Language)** | WebGPU | When targeting WebGPU renderer explicitly |
| **TSL (Three.js Shading Language)** | Three.js node materials | When using Three.js r160+ node-based system |

**GLSL version guidance:**
- GLSL ES 1.0 (WebGL 1) — Maximum compatibility but limited features
- GLSL ES 3.0 (WebGL 2) — Better features, 97%+ browser support
- Prefer GLSL ES 3.0 unless WebGL 1 fallback is required

**Shader type decision:**
| Shader Type | Purpose |
|------------|---------|
| Vertex shader | Transform vertex positions, pass data to fragment shader |
| Fragment shader | Calculate pixel color, lighting, effects |
| Post-processing | Full-screen effects applied after scene renders |

Most custom effects need both a vertex and fragment shader. Post-processing effects only need a fragment shader operating on the rendered scene texture.

**Output:** Shader language and type selection.

### Step 3: Implement Vertex Shader

Write the vertex shader that transforms vertex positions and prepares data for the fragment shader.

```glsl
// holographic.vert
precision highp float;

// Attributes (per-vertex data)
attribute vec3 position;
attribute vec3 normal;
attribute vec2 uv;

// Uniforms (shared data from JS)
uniform mat4 modelViewMatrix;
uniform mat4 projectionMatrix;
uniform mat3 normalMatrix;
uniform float uTime;
uniform float uDistortion;

// Varyings (passed to fragment shader)
varying vec3 vNormal;
varying vec3 vViewPosition;
varying vec2 vUv;

void main() {
  vUv = uv;
  vNormal = normalize(normalMatrix * normal);

  // Optional: vertex displacement for distortion effect
  vec3 displaced = position;
  displaced += normal * sin(position.y * 10.0 + uTime) * uDistortion;

  vec4 mvPosition = modelViewMatrix * vec4(displaced, 1.0);
  vViewPosition = -mvPosition.xyz;

  gl_Position = projectionMatrix * mvPosition;
}
```

Vertex shader considerations:
- Keep vertex shader simple — it runs per vertex, and complex meshes have many vertices
- Use uniforms for values that change per frame (time, mouse position)
- Use varyings to pass interpolated data to the fragment shader
- Vertex displacement should be subtle — large displacements break shadow maps

**Output:** Vertex shader implementation.

### Step 4: Implement Fragment Shader

Write the fragment shader that calculates the final pixel color.

```glsl
// holographic.frag
precision highp float;

uniform float uTime;
uniform vec3 uColor;
uniform float uFresnelPower;
uniform float uScanlineSpeed;
uniform float uScanlineCount;

varying vec3 vNormal;
varying vec3 vViewPosition;
varying vec2 vUv;

void main() {
  // Fresnel effect (rainbow shimmer based on viewing angle)
  vec3 viewDir = normalize(vViewPosition);
  float fresnel = pow(1.0 - abs(dot(viewDir, vNormal)), uFresnelPower);

  // Rainbow color based on fresnel and time
  vec3 rainbow = 0.5 + 0.5 * cos(
    6.28318 * (fresnel + uTime * 0.1 + vec3(0.0, 0.33, 0.67))
  );

  // Animated scan lines
  float scanline = smoothstep(
    0.3, 0.7,
    sin(vUv.y * uScanlineCount + uTime * uScanlineSpeed)
  );

  // Combine effects
  vec3 color = mix(uColor, rainbow, fresnel);
  color += scanline * 0.1;

  // Alpha based on fresnel (stronger at edges)
  float alpha = mix(0.3, 1.0, fresnel);

  gl_FragColor = vec4(color, alpha);
}
```

Fragment shader best practices:
- Minimize texture lookups (each is expensive on mobile)
- Avoid branching (`if` statements) — use `mix`, `step`, `smoothstep` instead
- Use `lowp`/`mediump` precision where possible on mobile
- Pre-compute values in vertex shader and pass via varyings when possible
- Test on mobile — fragment shaders are the most common mobile GPU bottleneck

**Output:** Fragment shader implementation.

### Step 5: Integrate with R3F and drei

Connect the custom shader to the React Three Fiber component tree.

**Using shaderMaterial (R3F extend):**
```tsx
import { shaderMaterial } from '@react-three/drei';
import { extend, useFrame } from '@react-three/fiber';

const HolographicMaterial = shaderMaterial(
  {
    uTime: 0,
    uColor: new THREE.Color('#00ffff'),
    uFresnelPower: 3.0,
    uScanlineSpeed: 2.0,
    uScanlineCount: 50.0,
    uDistortion: 0.02,
  },
  vertexShader,
  fragmentShader
);

extend({ HolographicMaterial });

function HolographicObject() {
  const materialRef = useRef();

  useFrame((state) => {
    materialRef.current.uTime = state.clock.elapsedTime;
  });

  return (
    <mesh>
      <sphereGeometry args={[1, 64, 64]} />
      <holographicMaterial
        ref={materialRef}
        transparent
        side={THREE.DoubleSide}
      />
    </mesh>
  );
}
```

**Using drei's MeshPortalMaterial, MeshTransmissionMaterial, etc.:**
- Check if drei already has a material that achieves a similar effect
- Extend drei materials instead of writing from scratch when possible

**Post-processing with @react-three/postprocessing:**
```tsx
import { EffectComposer, Bloom, ChromaticAberration } from '@react-three/postprocessing';

function Effects() {
  return (
    <EffectComposer>
      <Bloom luminanceThreshold={0.8} intensity={1.5} />
      <ChromaticAberration offset={[0.002, 0.002]} />
    </EffectComposer>
  );
}
```

**Output:** R3F integration with proper uniform updates and lifecycle management.

### Step 6: Test Performance Impact

Measure the shader's impact on frame rate and GPU utilization.

**Measurements:**
- Frame time with shader active vs. inactive
- GPU time attributed to shader (Spector.js or Chrome GPU profiling)
- Impact at different geometry complexity levels (low poly vs. high poly)
- Impact with multiple objects using the shader simultaneously

**Performance testing matrix:**
| Scenario | Objects | Triangles | FPS Without | FPS With | Delta |
|----------|---------|-----------|-------------|----------|-------|
| Single object | 1 | 10K | 60 | 59 | -1 |
| Multiple objects | 10 | 100K | 60 | 55 | -5 |
| Complex scene | 50 | 500K | 58 | 42 | -16 |

**Optimization if over budget:**
- Reduce fragment shader complexity (fewer texture lookups, simpler math)
- Lower geometry resolution on objects with this shader
- Use the shader selectively (only on focused/selected objects)
- Add LOD for shader complexity (simpler shader at distance)
- Pre-bake static effects into textures

**Output:** Performance impact report with optimization recommendations if needed.

---

## Quality Criteria

- The shader must achieve the specified visual effect accurately
- Performance impact must stay within the allocated frame budget
- The shader must work on both desktop and mobile WebGL
- All uniforms must be documented with their ranges and purposes
- The shader must be integrated cleanly into the R3F component tree

---

*Squad Apex — Custom Shader Design Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-shader-design
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Shader must achieve the specified visual effect as described in requirements"
    - "Performance impact must stay within the allocated frame budget (typically 2-4ms)"
    - "All uniforms must be documented with their ranges and purposes"
    - "Shader must be integrated cleanly into the R3F component tree with proper lifecycle management"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@perf-eng` or `@apex-lead` |
| Artifact | Visual effect specification, shader language selection, vertex and fragment shader implementations, R3F/drei integration, and performance impact assessment |
| Next action | Route to `@perf-eng` for `3d-performance-audit` if performance concerns exist, or integrate into scene via `scene-architecture` |
