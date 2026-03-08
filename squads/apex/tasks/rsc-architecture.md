# Task: rsc-architecture

```yaml
id: rsc-architecture
version: "1.0.0"
title: "React Server Component Architecture"
description: >
  Designs the Server Component boundaries for a feature or page.
  Audits the component tree for interactivity needs, identifies
  server-only data access, pushes 'use client' directives as far
  down as possible, and designs the server wrapper + client island
  pattern. Calculates JS bundle impact and documents all boundary
  decisions with rationale.
elicit: false
owner: react-eng
executor: react-eng
outputs:
  - Component tree with server/client annotations
  - Server-only data access catalog
  - Client boundary placement rationale
  - JS bundle impact assessment
  - Boundary decision documentation
```

---

## When This Task Runs

This task runs when:
- A new page or feature is being built in a Next.js App Router project
- An existing page needs to be migrated from Pages Router to App Router
- Client bundle size is too large and server components can reduce it
- The team needs clarity on where to place `'use client'` boundaries
- `*rsc-design` or `*server-components` is invoked

This task does NOT run when:
- The project does not use React Server Components (Pages Router only, Vite SPA)
- The task is purely about client-side state management
- The task is about API route design (not component architecture)

---

## Execution Steps

### Step 1: Audit Component Tree for Interactivity Needs

Walk the component tree from the page root and mark each component based on its interactivity requirements.

For each component, assess:
- **Does it use hooks?** (`useState`, `useReducer`, `useEffect`, `useRef` with DOM, `useContext`)
- **Does it have event handlers?** (`onClick`, `onChange`, `onSubmit`, `onKeyDown`, etc.)
- **Does it use browser APIs?** (`window`, `document`, `localStorage`, `navigator`, `IntersectionObserver`)
- **Does it use third-party client libraries?** (Framer Motion, react-hook-form, Zustand, etc.)

Mark each component:
- `[S]` — Can be a Server Component (no interactivity needed)
- `[C]` — MUST be a Client Component (has interactivity)
- `[?]` — Could be either (needs design decision)

```
Page [S]
├── Header [S]
│   ├── Logo [S]
│   ├── Navigation [S]
│   └── UserMenu [C] — uses useState for open/close
├── SearchSection [?]
│   ├── SearchInput [C] — onChange handler
│   └── SearchResults [S] — renders static list
├── ContentGrid [S]
│   └── ContentCard [S]
│       └── FavoriteButton [C] — onClick handler
└── Footer [S]
```

**Output:** Annotated component tree.

### Step 2: Identify Server-Only Data Access

Catalog all data fetching in the feature and determine which can happen exclusively on the server.

Server-only data access patterns:
- Direct database queries (Prisma, Drizzle, raw SQL)
- Server-side API calls with secrets (API keys, tokens that must not be exposed to client)
- File system reads (`fs.readFile`)
- Environment variables that are server-only (`process.env.DATABASE_URL`)
- Heavy data transformations that should not run in the browser

For each data access:
- Can it happen at build time (`generateStaticParams`)?
- Can it happen at request time (Server Component `async function`)?
- Does it need client state to determine the query (e.g., search input value)?

If data depends on client state, the **fetching** still happens on the server via Server Actions or route handlers — only the **trigger** is on the client.

**Output:** Data access catalog with server/client classification.

### Step 3: Push 'use client' as Far Down as Possible

Apply the core RSC principle: maximize the server component surface area by pushing client boundaries to leaf nodes.

**Strategy:**
```
BAD:  Mark entire page as 'use client' because one button needs onClick
GOOD: Keep page as server, only mark the button component as 'use client'
```

For each `[C]` component identified in Step 1:
- Can the interactive part be extracted into a smaller child component?
- Can the parent remain a Server Component by passing server-fetched data as props to the client child?
- Can `children` prop be used to pass server-rendered content through a client component?

**Pattern: Passing Server Content Through Client Components**
```tsx
// ClientLayout.tsx ('use client')
function ClientLayout({ children }) {
  const [isOpen, setIsOpen] = useState(false);
  return <div className={isOpen ? 'expanded' : 'collapsed'}>{children}</div>;
}

// Page.tsx (Server Component)
function Page() {
  const data = await fetchData(); // server-only
  return (
    <ClientLayout>
      <ServerContent data={data} /> {/* This stays on the server! */}
    </ClientLayout>
  );
}
```

**Output:** Revised component tree with optimized client boundaries.

### Step 4: Design Server Wrapper + Client Island Patterns

For each client boundary, design the specific pattern for passing data from server to client.

**Pattern A: Server Data Prop Drilling**
```tsx
// Server Component fetches, passes to client
async function ProductPage({ id }) {
  const product = await getProduct(id);
  return <ProductInteractions product={product} />;
}
```

**Pattern B: Suspense Boundary**
```tsx
// Server Component wraps async child in Suspense
function Dashboard() {
  return (
    <Suspense fallback={<StatsLoading />}>
      <StatsPanel /> {/* async server component */}
    </Suspense>
  );
}
```

**Pattern C: Server Action for Mutations**
```tsx
// Server Action defined in server component
async function updateProfile(formData: FormData) {
  'use server';
  await db.profile.update({ ... });
  revalidatePath('/profile');
}

// Passed to client form
function ProfilePage() {
  return <ProfileForm action={updateProfile} />;
}
```

For each client island, document:
- What data it receives from the server (props)
- What server actions it can invoke (mutations)
- What client-only state it manages

**Output:** Pattern specification for each server-client boundary.

### Step 5: Calculate JS Bundle Impact

Estimate the JavaScript that will be sent to the client and identify optimization opportunities.

- List all `'use client'` components and their approximate sizes
- Identify third-party libraries that will be included in the client bundle due to client components importing them
- Calculate the total client JS footprint
- Compare with a baseline (if everything were a client component)
- Identify components marked as client that could potentially be converted to server components with refactoring

**Optimization opportunities:**
- Replace heavy client libraries with server-side alternatives
- Lazy load client components that are below the fold (`dynamic()` with `ssr: false`)
- Use `React.lazy` for client components not needed on initial render
- Move computed/derived data to the server to reduce client-side processing

**Output:** Client bundle impact assessment with before/after comparison.

### Step 6: Document Boundary Decisions

Create a decision document that future developers can reference to understand why each boundary exists.

For each `'use client'` directive:
- **Component:** Name and file path
- **Reason:** Why this must be a client component
- **Could it be server?** What would need to change
- **Dependencies:** What client libraries does it pull into the bundle
- **Data flow:** What props does it receive from server components

Include a visual diagram of the final component tree with server/client annotations and data flow arrows.

**Output:** RSC boundary decision document.

---

## Quality Criteria

- No `'use client'` at the page level unless every single child truly needs client features
- Every client boundary must have a documented reason
- Server-only data (secrets, DB queries) must never be accessible from client components
- The client bundle must be smaller than a full-client-rendering baseline
- Suspense boundaries must be placed at meaningful loading state boundaries

---

*Squad Apex — RSC Architecture Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-rsc-architecture
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Component tree must have server/client annotations for every component"
    - "Every 'use client' boundary must have a documented reason"
    - "Server-only data (secrets, DB queries) must never be accessible from client components"
    - "JS bundle impact assessment must include before/after comparison"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@perf-eng` or `@apex-lead` |
| Artifact | Component tree with server/client annotations, data access catalog, client boundary rationale, and JS bundle impact assessment |
| Next action | Route to `@perf-eng` for bundle impact validation or to `@frontend-arch` for `rsc-boundary-audit` |
