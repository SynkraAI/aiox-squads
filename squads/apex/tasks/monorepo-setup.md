# Task: monorepo-setup

```yaml
id: monorepo-setup
version: "1.0.0"
title: "Cross-Platform Monorepo Setup"
description: >
  Sets up a cross-platform monorepo structure using Turborepo that
  supports web (Next.js) and native (React Native / Expo) applications
  with shared packages. Configures workspace dependencies, build
  pipelines, and import rules to ensure clean boundaries between
  shared and platform-specific code.
elicit: false
owner: cross-plat-eng
executor: cross-plat-eng
outputs:
  - Turborepo workspace configuration
  - Shared package structure
  - Platform-specific app configurations
  - Build pipeline definitions
  - Import rule validation
  - Structure documentation
```

---

## When This Task Runs

This task runs when:
- A new cross-platform project is being bootstrapped
- An existing project needs to support both web and native from a single repo
- The team wants to share code between web and native apps
- Monorepo configuration needs to be restructured for better boundaries
- `*monorepo-setup` or `*setup-monorepo` is invoked

This task does NOT run when:
- The project is single-platform (web-only or native-only)
- Only a single package needs adjustment (not a monorepo concern)
- The task is about CI/CD pipeline changes (delegate to `@devops`)

---

## Execution Steps

### Step 1: Configure Turborepo Workspace

Set up the root workspace configuration with Turborepo.

Root `package.json`:
```json
{
  "name": "my-app",
  "private": true,
  "workspaces": ["apps/*", "packages/*"],
  "devDependencies": {
    "turbo": "^2.0.0"
  }
}
```

Root `turbo.json`:
```json
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": [".env"],
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "dist/**", "build/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^build"]
    },
    "typecheck": {
      "dependsOn": ["^build"]
    },
    "test": {
      "dependsOn": ["^build"]
    }
  }
}
```

Configure TypeScript project references for cross-package type checking:
- Root `tsconfig.json` with shared compiler options
- Each package has its own `tsconfig.json` extending root
- Project references enable incremental builds

**Output:** Root workspace and Turborepo configuration files.

### Step 2: Define Shared Packages

Design the shared package structure that contains platform-agnostic code.

```
packages/
├── ui/                    # Shared UI components (universal)
│   ├── src/
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.web.tsx
│   │   │   ├── Button.native.tsx
│   │   │   └── Button.types.ts
│   │   └── index.ts
│   ├── package.json
│   └── tsconfig.json
├── app/                   # Shared app logic (screens, features)
│   ├── src/
│   │   ├── features/
│   │   │   ├── home/
│   │   │   └── profile/
│   │   └── index.ts
│   ├── package.json
│   └── tsconfig.json
├── api/                   # Shared API client and types
│   ├── src/
│   │   ├── client.ts
│   │   ├── types.ts
│   │   └── hooks/
│   ├── package.json
│   └── tsconfig.json
├── tokens/                # Design tokens (shared values)
│   ├── src/
│   │   ├── colors.ts
│   │   ├── spacing.ts
│   │   └── typography.ts
│   ├── package.json
│   └── tsconfig.json
└── utils/                 # Pure utility functions
    ├── src/
    │   ├── format.ts
    │   ├── validation.ts
    │   └── date.ts
    ├── package.json
    └── tsconfig.json
```

Package design rules:
- **No platform imports in shared packages** — `packages/utils` cannot import from `react-native` or `next`
- **Platform-specific code uses file extensions** — `.web.tsx` / `.native.tsx`
- **Each package has explicit exports** — `package.json` `exports` field
- **Internal packages use `"main": "./src/index.ts"`** — no build step needed for development

**Output:** Shared package directory structure with package.json files.

### Step 3: Set Up Platform-Specific Apps

Configure the web and native applications that consume shared packages.

```
apps/
├── web/                   # Next.js application
│   ├── app/               # App Router pages
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   └── (routes)/
│   ├── next.config.js     # Transpile shared packages
│   ├── tailwind.config.ts # Include shared package paths
│   ├── package.json
│   └── tsconfig.json
├── mobile/                # Expo / React Native application
│   ├── app/               # Expo Router pages
│   │   ├── _layout.tsx
│   │   ├── index.tsx
│   │   └── (tabs)/
│   ├── metro.config.js    # Resolve shared packages
│   ├── app.json
│   ├── package.json
│   └── tsconfig.json
└── storybook/             # Storybook for component development (optional)
    ├── .storybook/
    ├── package.json
    └── tsconfig.json
```

**Next.js configuration:**
```javascript
// apps/web/next.config.js
const { withNativeWind } = require('nativewind/next');

module.exports = withNativeWind({
  transpilePackages: ['@app/ui', '@app/app', '@app/api', '@app/tokens'],
  experimental: {
    optimizePackageImports: ['@app/ui'],
  },
}, { mode: 'web' });
```

**Metro configuration:**
```javascript
// apps/mobile/metro.config.js
const { getDefaultConfig } = require('expo/metro-config');
const { withNativeWind } = require('nativewind/metro');
const path = require('path');

const projectRoot = __dirname;
const monorepoRoot = path.resolve(projectRoot, '../..');

const config = getDefaultConfig(projectRoot);
config.watchFolders = [monorepoRoot];
config.resolver.nodeModulesPaths = [
  path.resolve(projectRoot, 'node_modules'),
  path.resolve(monorepoRoot, 'node_modules'),
];

module.exports = withNativeWind(config, { input: './global.css' });
```

**Output:** Web and native app configurations with shared package integration.

### Step 4: Configure Build Pipelines

Set up build tasks that respect the dependency graph.

```json
{
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "dist/**"],
      "env": ["NODE_ENV", "API_URL"]
    },
    "build:web": {
      "dependsOn": ["^build"],
      "outputs": [".next/**"]
    },
    "build:mobile": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    },
    "dev:web": {
      "cache": false,
      "persistent": true,
      "dependsOn": ["^build"]
    },
    "dev:mobile": {
      "cache": false,
      "persistent": true,
      "dependsOn": ["^build"]
    }
  }
}
```

Build pipeline rules:
- Shared packages build before apps (`dependsOn: ["^build"]`)
- Dev tasks are not cached (`cache: false`)
- Environment variables are declared for cache invalidation
- Outputs are specified for remote caching

Verify the build graph:
```bash
turbo build --graph  # Visualize dependency graph
turbo build --dry    # Show what would run without executing
```

**Output:** Build pipeline configuration with task dependencies.

### Step 5: Validate Import Rules

Enforce import boundaries to prevent cross-platform contamination.

**Rules:**
1. `packages/utils` — NO React, NO React Native, NO Next.js imports
2. `packages/tokens` — NO React imports (pure values only)
3. `packages/ui` — React allowed, platform code only in `.web.tsx` / `.native.tsx`
4. `packages/app` — React + Solito allowed, no direct `next` or `react-native` imports
5. `packages/api` — React allowed (for hooks), no platform-specific code
6. `apps/web` — Can import from any package + Next.js
7. `apps/mobile` — Can import from any package + React Native / Expo

Enforce with ESLint `no-restricted-imports`:
```javascript
// packages/utils/.eslintrc.js
module.exports = {
  rules: {
    'no-restricted-imports': ['error', {
      patterns: ['react', 'react-native', 'next/*', 'expo-*']
    }]
  }
};
```

Verify imports are clean:
- Run `turbo lint` across all packages
- Check that `packages/utils` has zero React imports
- Check that `packages/app` has zero `next` or `react-native` direct imports

**Output:** Import rule configuration and validation results.

### Step 6: Document Structure

Create clear documentation for the monorepo structure.

Document:
- Directory map with purpose of each package and app
- How to add a new shared component
- How to add a new screen/feature
- How to add a new shared package
- Development workflow (which `turbo` commands to run)
- Deployment workflow (how each app is built and deployed)
- Import rules and how to check them
- Troubleshooting common issues (Metro resolution, Next.js transpilation)

**Output:** Monorepo structure documentation.

---

## Quality Criteria

- All shared packages must be importable from both web and native apps
- `turbo build` must complete successfully with correct task ordering
- Import rules must be enforced and verifiable with lint
- Platform-specific code must never leak into shared packages
- Development hot-reload must work for both web and native simultaneously

---

*Squad Apex — Cross-Platform Monorepo Setup Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-monorepo-setup
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "All shared packages must be importable from both web and native apps"
    - "turbo build must complete successfully with correct task ordering"
    - "Import rules must be enforced and pass lint validation"
    - "Platform-specific code must be isolated to .web.tsx / .native.tsx files"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@apex-lead` |
| Artifact | Complete monorepo configuration with Turborepo, shared packages, platform apps, and import validation |
| Next action | Route to `@frontend-arch` for `monorepo-structure` validation or coordinate with `@devops` for CI pipeline setup |
