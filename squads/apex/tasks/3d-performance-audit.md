# Task: 3d-performance-audit

```yaml
id: 3d-performance-audit
version: "1.0.0"
title: "3D Rendering Performance Audit"
description: >
  Audits the performance of a 3D rendering scene by measuring draw
  calls, geometry complexity, texture memory, and GPU usage.
  Optimizes using instancing, LOD, texture compression, and geometry
  reduction. Tests on target devices to verify performance budgets
  are met.
elicit: false
owner: spatial-eng
executor: spatial-eng
outputs:
  - Draw call analysis
  - Geometry complexity report (triangle count)
  - Texture memory audit
  - GPU usage profile
  - Optimization recommendations with instancing/LOD
  - Target device test results
```

---

## When This Task Runs

This task runs when:
- A 3D scene is dropping below target frame rate (60fps desktop, 30fps mobile)
- The scene is visually stuttering or janky during interaction
- New 3D content has been added and performance impact is unknown
- Before shipping a 3D feature to production
- `*3d-perf` or `*audit-3d-performance` is invoked

This task does NOT run when:
- The scene is being designed from scratch (use `scene-architecture` first)
- The issue is a shader compilation problem (use `shader-design`)
- The performance issue is in the React layer, not the 3D renderer

---

## Execution Steps

### Step 1: Measure Draw Calls

Analyze the number of draw calls per frame and identify reduction opportunities.

**What is a draw call?**
Each time the GPU is asked to render a set of triangles with a specific material, that is one draw call. More draw calls = more CPU overhead coordinating with the GPU.

**Measurement:**
```tsx
function PerformanceMonitor() {
  const { gl } = useThree();

  useFrame(() => {
    const info = gl.info.render;
    console.log({
      drawCalls: info.calls,
      triangles: info.triangles,
      points: info.points,
      lines: info.lines,
    });
    gl.info.reset(); // Reset per-frame counters
  });

  return null;
}
```

**Target:** < 100 draw calls per frame on desktop, < 50 on mobile.

**Common causes of excessive draw calls:**
- Each mesh with a unique material = 1 draw call
- Same geometry with different materials = separate draw calls
- Transparent objects sorted individually
- Shadow map rendering doubles draw calls for shadow-casting objects

**Reduction strategies:**
- **Merge static geometry:** Use `BufferGeometryUtils.mergeGeometries()` for static objects with the same material
- **Use instancing:** Replace duplicate meshes with `<Instances>` from drei
- **Reduce materials:** Share materials across meshes where possible
- **Batch transparent objects:** Group transparent objects to reduce sort overhead

**Output:** Draw call count with breakdown by scene section.

### Step 2: Check Geometry Complexity (Triangle Count)

Audit the total triangle count and identify overly complex geometry.

**Measurement:**
```typescript
function countTriangles(scene: THREE.Scene): number {
  let total = 0;
  scene.traverse((obj) => {
    if (obj instanceof THREE.Mesh) {
      const geo = obj.geometry;
      if (geo.index) {
        total += geo.index.count / 3;
      } else {
        total += geo.attributes.position.count / 3;
      }
    }
  });
  return total;
}
```

**Budgets:**
| Target | Triangle Budget |
|--------|----------------|
| Desktop (WebGL) | < 500,000 |
| Mobile web | < 100,000 |
| VR (Quest) | < 200,000 per eye |

**Per-object analysis:**
- List the top 10 heaviest objects by triangle count
- For each: is this complexity visible to the user? (Objects far from camera need fewer triangles)
- Flag objects where triangle count exceeds visual benefit

**Reduction strategies:**
- **Decimation:** Reduce vertex count with mesh simplification tools (Blender decimate modifier, `meshoptimizer`)
- **LOD (Level of Detail):** Show simpler geometry at distance
  ```tsx
  <LOD>
    <mesh geometry={highPoly} /> {/* distance 0-10 */}
    <mesh geometry={medPoly} />  {/* distance 10-50 */}
    <mesh geometry={lowPoly} />  {/* distance 50+ */}
  </LOD>
  ```
- **Normal maps:** Replace geometric detail with normal maps (visual detail without triangles)
- **Remove hidden faces:** Delete geometry that will never be visible (interior faces, backfaces)

**Output:** Triangle count breakdown with per-object analysis.

### Step 3: Audit Texture Memory

Analyze texture sizes, formats, and total GPU memory usage.

**Measurement:**
```typescript
const textureMemory = gl.info.memory.textures; // Number of textures
// For detailed size, inspect each texture:
scene.traverse((obj) => {
  if (obj.material?.map) {
    const tex = obj.material.map;
    const bytes = tex.image.width * tex.image.height * 4; // RGBA
    console.log(`${tex.name}: ${tex.image.width}x${tex.image.height} = ${bytes / 1024 / 1024}MB`);
  }
});
```

**Common texture issues:**
- Textures larger than necessary (4096x4096 when 1024x1024 would suffice)
- Uncompressed PNG/JPEG instead of GPU-compressed formats (KTX2, Basis)
- Duplicate textures loaded multiple times
- Unused textures still in memory
- No mipmaps generated (blurry at distance OR wasted memory)

**Optimization strategies:**
- **Right-size textures:** Match texture resolution to screen pixel coverage
- **Use GPU compression:** KTX2 with Basis Universal — 4-8x smaller in GPU memory
  ```tsx
  import { KTX2Loader } from 'three/examples/jsm/loaders/KTX2Loader';
  ```
- **Texture atlases:** Combine multiple small textures into one atlas
- **Share textures:** Use the same material/texture instance across objects
- **Dispose unused:** Call `texture.dispose()` when no longer needed

**Output:** Texture inventory with size, format, and optimization recommendations.

### Step 4: Profile GPU Usage

Analyze GPU utilization to identify bottlenecks.

**Tools:**
- **Chrome DevTools → Performance tab:** Frame timing, GPU tasks
- **Chrome → `chrome://gpu`:** GPU feature status and renderer info
- **Spector.js:** WebGL call inspector (captures every GL call in a frame)
- **Three.js Stats:** FPS, MS (frame time), MB (memory)

**Key metrics:**
| Metric | Target | Red Flag |
|--------|--------|----------|
| Frame time | < 16.67ms (60fps) | > 20ms |
| GPU time | < 12ms per frame | > 14ms |
| Shader compilation | < 100ms per shader | > 500ms (stutter) |
| Texture upload | < 50ms per texture | > 200ms (frame drop) |

**GPU bottleneck identification:**
- **Fill rate limited:** Too many pixels being drawn (large transparent objects, overdraw)
  - Fix: Reduce overdraw, use occlusion culling, reduce transparency
- **Vertex processing limited:** Too many vertices per frame
  - Fix: Reduce triangle count, use LOD
- **Texture bandwidth limited:** Too much texture data being sampled
  - Fix: Smaller textures, GPU compression, reduce texture reads in shaders
- **Shader complexity limited:** Fragment shader too expensive
  - Fix: Simplify shaders, reduce per-pixel computations

**Output:** GPU profile with bottleneck identification.

### Step 5: Optimize with Instancing and LOD

Apply the specific optimizations identified in previous steps.

**Instancing (for repeated objects):**
```tsx
import { Instances, Instance } from '@react-three/drei';

function Forest() {
  return (
    <Instances limit={1000} range={1000}>
      <boxGeometry />
      <meshStandardMaterial />
      {trees.map((tree, i) => (
        <Instance
          key={i}
          position={tree.position}
          scale={tree.scale}
          color={tree.color}
        />
      ))}
    </Instances>
  );
}
// 1000 trees = 1 draw call instead of 1000
```

**LOD implementation:**
```tsx
import { Detailed } from '@react-three/drei';

function Building() {
  return (
    <Detailed distances={[0, 25, 50, 100]}>
      <HighDetailBuilding />    {/* 0-25m: full detail */}
      <MediumDetailBuilding />  {/* 25-50m: reduced */}
      <LowDetailBuilding />     {/* 50-100m: simple */}
      <BillboardBuilding />     {/* 100m+: flat image */}
    </Detailed>
  );
}
```

**Frustum culling:** Enabled by default in Three.js — verify it is not disabled.

**Occlusion culling:** For complex indoor scenes, implement portal-based or BSP-based culling.

**Output:** Applied optimizations with before/after metrics.

### Step 6: Test on Target Devices

Verify performance on actual target hardware.

**Desktop testing:**
- Test on integrated GPU (Intel/AMD) — worst case for desktop users
- Test on dedicated GPU (NVIDIA/AMD) — expected performance
- Test in Chrome, Firefox, Safari (WebGL implementations differ)

**Mobile testing:**
- Test on mid-range phone (the floor, not the ceiling)
- Test with device thermal throttling (run benchmark for 5+ minutes)
- Check battery impact

**VR testing (if applicable):**
- Test on Quest 2/3 (standalone, limited GPU)
- Verify stereo rendering performance (2x rendering cost)
- Check for motion sickness indicators (frame drops during head movement)

**Results table:**
| Device | GPU | FPS (idle) | FPS (interaction) | Triangle count | Draw calls | Pass? |
|--------|-----|-----------|-------------------|---------------|------------|-------|
| MacBook Air M1 | Integrated | 60 | 58 | 320K | 78 | YES |
| iPhone 13 | A15 | 55 | 48 | 95K | 42 | YES |
| Quest 3 | Adreno 740 | 72 | 65 | 180K | 55 | YES |

**Output:** Device test results with pass/fail against performance budgets.

---

## Quality Criteria

- Every optimization must have measured before/after metrics
- Draw calls must be below budget on all target devices
- Triangle count must be below budget with LOD active
- No frame drops below 30fps on any target device during normal interaction
- Texture memory must not exceed GPU memory limits on target devices

---

*Squad Apex — 3D Rendering Performance Audit Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-3d-performance-audit
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Verdict must be explicitly stated (PASS/FAIL/NEEDS_WORK)"
    - "Draw call count, triangle count, and texture memory must be measured and reported"
    - "Optimization recommendations must include at least instancing, LOD, or texture compression"
    - "Target device test results must cover at least one flagship and one budget device"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | 3D performance audit report with optimization recommendations |
| Next action | Route optimizations to `@spatial-eng` for implementation or escalate to `@perf-eng` if budget violations are systemic |
