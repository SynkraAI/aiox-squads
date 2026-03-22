# Task: image-optimization

```yaml
id: image-optimization
version: "1.0.0"
title: "Image Optimization"
description: >
  Optimizes image loading and format across the application.
  Audits current image usage, converts to modern formats
  (WebP/AVIF), implements responsive images with srcset,
  adds lazy loading, sets up an image optimization pipeline,
  and verifies LCP impact.
elicit: false
owner: perf-eng
executor: perf-eng
outputs:
  - Image usage audit
  - Format conversion plan (WebP/AVIF)
  - Responsive image implementation (srcset)
  - Lazy loading implementation
  - Image CDN/optimization pipeline
  - LCP impact verification
  - Optimization pipeline documentation
```

---

## When This Task Runs

This task runs when:
- Images are the largest contributor to page weight
- LCP element is an image that loads slowly
- CLS is caused by images without dimensions
- The project uses only JPEG/PNG without modern formats
- `*image-opt` or `*optimize-images` is invoked

This task does NOT run when:
- A full performance audit is needed (use `performance-audit`)
- Only JavaScript bundle size is the concern (use `bundle-optimization`)
- Images are primarily 3D textures (delegate to `@spatial-eng`)

---

## Execution Steps

### Step 1: Audit Current Image Usage

Catalog all images in the application with their current format, size, and usage context.

**Image inventory:**
| # | Image | Format | Dimensions | File Size | Used On | Above Fold? | LCP Candidate? |
|---|-------|--------|-----------|-----------|---------|-------------|---------------|
| 1 | hero-banner.jpg | JPEG | 1920x1080 | 450KB | Homepage | Yes | Yes |
| 2 | team-photo.png | PNG | 800x600 | 320KB | About | Yes | No |
| 3 | icon-set.svg | SVG | Various | 15KB | Global | Yes | No |

**What to check for each image:**
- Is the image larger than its rendered size? (A 3000px image displayed at 400px is wasted bytes)
- Is the format optimal for the content type? (Photos → JPEG/WebP/AVIF, Graphics → SVG/PNG)
- Does the image have width and height attributes? (Missing dimensions cause CLS)
- Is the image lazy-loaded if below the fold?
- Is the image preloaded if it is the LCP element?

**Total image weight:**
```
Total images: {N}
Total weight: {size}MB
Average per page: {size}KB
Largest single image: {name} at {size}KB
```

**Output:** Complete image inventory with optimization flags.

### Step 2: Convert to Modern Formats (WebP/AVIF)

Convert images from legacy formats to modern, efficient formats.

**Format comparison:**

| Format | Compression | Browser Support | Best For |
|--------|------------|-----------------|----------|
| JPEG | Lossy, good | 100% | Photos (legacy) |
| PNG | Lossless | 100% | Graphics with transparency (legacy) |
| WebP | Lossy + lossless, 25-35% smaller than JPEG | 97%+ | Photos (modern default) |
| AVIF | Lossy + lossless, 50% smaller than JPEG | 92%+ | Photos (best compression) |
| SVG | Vector | 100% | Icons, logos, illustrations |

**Conversion strategy:**
```html
<!-- Use <picture> element for format fallback -->
<picture>
  <source srcset="/hero.avif" type="image/avif" />
  <source srcset="/hero.webp" type="image/webp" />
  <img src="/hero.jpg" alt="Hero banner" width="1920" height="1080" />
</picture>
```

**Quality settings:**
| Format | Quality Setting | Visual Quality | Use Case |
|--------|---------------|----------------|----------|
| WebP | 80 | Near-identical to JPEG at 85 | Default for photos |
| WebP | 90 | Visually lossless | Hero images, product photos |
| AVIF | 60 | Comparable to WebP at 80 | When AVIF is supported |
| AVIF | 75 | Near-lossless | Critical imagery |

**Batch conversion:**
```bash
# Using sharp (Node.js)
npx sharp-cli --input "images/*.jpg" --output "images/webp/" --format webp --quality 80
npx sharp-cli --input "images/*.jpg" --output "images/avif/" --format avif --quality 65

# Using ImageMagick
mogrify -format webp -quality 80 images/*.jpg
```

**Expected savings:**
| Image | Original (JPEG) | WebP | AVIF | Savings |
|-------|-----------------|------|------|---------|
| hero-banner | 450KB | 310KB | 225KB | 50% (AVIF) |
| team-photo | 320KB | 220KB | 160KB | 50% (AVIF) |

**Output:** Format conversion plan with expected savings.

### Step 3: Implement Responsive Images (srcset)

Serve appropriately sized images for different viewport widths and pixel densities.

**srcset with width descriptors:**
```html
<img
  srcset="
    hero-400w.webp   400w,
    hero-800w.webp   800w,
    hero-1200w.webp 1200w,
    hero-1600w.webp 1600w,
    hero-2000w.webp 2000w
  "
  sizes="
    (max-width: 640px) 100vw,
    (max-width: 1024px) 80vw,
    50vw
  "
  src="hero-1200w.webp"
  alt="Hero banner"
  width="2000"
  height="1125"
/>
```

**Next.js Image component (recommended for Next.js projects):**
```tsx
import Image from 'next/image';

<Image
  src="/hero-banner.jpg"
  alt="Hero banner"
  width={2000}
  height={1125}
  sizes="(max-width: 640px) 100vw, (max-width: 1024px) 80vw, 50vw"
  priority  // For LCP images
/>
```

**Breakpoint strategy for image widths:**
| Viewport | Typical Image Display | Image Width Needed |
|----------|----------------------|-------------------|
| 320px (mobile) | Full width | 640px (2x density) |
| 768px (tablet) | 80% width | 1228px (2x density) |
| 1440px (desktop) | 50% width | 1440px (2x density) |

**Generation sizes:**
Create 5 sizes per image: 400w, 800w, 1200w, 1600w, 2000w. This covers most viewport and density combinations without excessive variants.

**Output:** Responsive image implementation for all audited images.

### Step 4: Add Lazy Loading

Implement lazy loading for below-the-fold images to reduce initial page weight.

**Native lazy loading (recommended):**
```html
<!-- Below-the-fold images: lazy load -->
<img src="product.webp" alt="Product" loading="lazy" />

<!-- Above-the-fold images: eager load (default, but be explicit) -->
<img src="hero.webp" alt="Hero" loading="eager" />

<!-- LCP image: eager + fetchpriority high -->
<img src="hero.webp" alt="Hero" loading="eager" fetchpriority="high" />
```

**Rules:**
- **NEVER lazy-load the LCP image** — this delays the most important visual element
- **ALWAYS lazy-load images below the fold** — they are not needed immediately
- **Set fetchpriority="high" on the LCP image** — tells the browser to prioritize this resource
- **Set decoding="async" on non-critical images** — allows the browser to decode off the main thread

**Next.js approach:**
```tsx
// LCP image: priority prop (disables lazy loading, adds fetchpriority)
<Image src="/hero.jpg" alt="Hero" priority />

// Below fold: lazy by default in Next.js Image
<Image src="/product.jpg" alt="Product" />

// Explicit placeholder for better UX
<Image src="/product.jpg" alt="Product" placeholder="blur" blurDataURL={blurHash} />
```

**Intersection Observer fallback (for complex lazy loading):**
```typescript
const observer = new IntersectionObserver((entries) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      const img = entry.target as HTMLImageElement;
      img.src = img.dataset.src!;
      observer.unobserve(img);
    }
  });
}, { rootMargin: '200px' }); // Start loading 200px before visible
```

**Output:** Lazy loading implementation with LCP image properly prioritized.

### Step 5: Set Up Image CDN/Optimization Pipeline

Configure an image optimization pipeline for consistent, automated optimization.

**Option A: Next.js Image Optimization (built-in)**
```javascript
// next.config.js
module.exports = {
  images: {
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    remotePatterns: [
      { protocol: 'https', hostname: 'images.example.com' },
    ],
  },
};
```

**Option B: Image CDN (Cloudinary, Imgix, Cloudflare Images)**
```html
<!-- Cloudinary URL transformation -->
<img src="https://res.cloudinary.com/demo/image/upload/w_800,f_auto,q_auto/hero.jpg" />
<!-- f_auto: automatic format (AVIF > WebP > JPEG) -->
<!-- q_auto: automatic quality based on content -->
<!-- w_800: resize to 800px width -->
```

**Option C: Build-time optimization (static sites)**
```javascript
// sharp in build pipeline
import sharp from 'sharp';

async function optimizeImage(input: string, outputDir: string) {
  const image = sharp(input);
  const metadata = await image.metadata();

  const widths = [400, 800, 1200, 1600, 2000];
  for (const width of widths) {
    if (width <= metadata.width!) {
      await image.resize(width).webp({ quality: 80 }).toFile(`${outputDir}/${width}w.webp`);
      await image.resize(width).avif({ quality: 65 }).toFile(`${outputDir}/${width}w.avif`);
    }
  }
}
```

**Output:** Image optimization pipeline configuration.

### Step 6: Verify LCP Impact

Measure how image optimizations affect Largest Contentful Paint.

**Before optimization:**
- LCP time: {X}s
- LCP element: {image name}
- LCP image size: {X}KB
- LCP image format: {JPEG/PNG}

**After optimization:**
- LCP time: {X}s
- LCP element: {same image}
- LCP image size: {X}KB
- LCP image format: {AVIF/WebP}
- fetchpriority: high
- preload: yes/no

**LCP-specific optimizations applied:**
- [ ] Converted to AVIF/WebP (smaller file = faster download)
- [ ] Added `fetchpriority="high"` (browser prioritizes this resource)
- [ ] Added `<link rel="preload">` in `<head>` (starts download immediately)
- [ ] Removed lazy loading from LCP image
- [ ] Ensured no render-blocking resources delay LCP image display
- [ ] Used responsive image to serve appropriate size for viewport

**Output:** LCP before/after comparison with specific optimizations attributed.

### Step 7: Document Pipeline

Document the image optimization workflow for ongoing use.

- How to add a new image to the project
- What formats to provide (or how they are auto-generated)
- How responsive sizes are determined
- When to use lazy loading vs. eager loading
- How the CDN/optimization pipeline works
- How to verify optimization is working (checking served format in Network tab)

**Output:** Image optimization pipeline documentation.

---

## Quality Criteria

- All images must be served in WebP or AVIF format (with JPEG fallback)
- All images must have explicit width and height attributes
- LCP image must NOT be lazy loaded and must have fetchpriority="high"
- Below-the-fold images must be lazy loaded
- Responsive images must serve appropriate sizes (not oversized for viewport)
- Total image weight reduction must be measured and reported

---

*Squad Apex — Image Optimization Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-image-optimization
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "All images must be served in WebP or AVIF format with fallback"
    - "All images must have explicit width and height attributes"
    - "LCP image must NOT be lazy loaded and must have fetchpriority=high"
    - "LCP before/after comparison must show measurable improvement"
    - "Total image weight reduction must be measured and reported"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Image optimization report with format conversion, responsive images, lazy loading, and LCP verification |
| Next action | Route to `@frontend-arch` for `performance-budget-review` if LCP targets changed, or confirm optimization complete |
