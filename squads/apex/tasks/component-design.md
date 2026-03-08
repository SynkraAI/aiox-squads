# Task: component-design

```yaml
id: component-design
version: "1.0.0"
title: "React Component Design"
description: >
  Designs the architecture for a React component or component group,
  following modern React patterns. Defines responsibilities, state
  categorization, composition patterns, server/client boundaries,
  props API, and testing approach. Ensures the component is
  maintainable, composable, and testable from the start.
elicit: false
owner: react-eng
executor: react-eng
outputs:
  - Component responsibility definition
  - State categorization (server/UI/form/URL)
  - Composition pattern selection with rationale
  - Server vs client boundary decision
  - Props API specification
  - Testing approach outline
```

---

## When This Task Runs

This task runs when:
- A new component or component group needs to be built
- An existing component needs significant redesign (not just a bug fix)
- A story requires a component that does not exist yet
- The team needs to decide on the right composition pattern for a complex UI
- `*design-component` or `*component` is invoked

This task does NOT run when:
- A component already exists and only needs a minor fix
- The task is purely CSS/styling (delegate to `@css-eng`)
- The task is purely about animation (delegate to `@motion-eng`)
- The task is about design system token mapping (delegate to `@design-sys-eng`)

---

## Execution Steps

### Step 1: Define Component Responsibilities

Clearly articulate what the component does and what it does NOT do.

- Write a one-sentence description of the component's purpose
- List the primary responsibilities (what it renders, what interactions it handles)
- List explicit non-responsibilities (what it delegates to parent or child components)
- Apply the Single Responsibility Principle: if the component does more than one conceptual thing, consider splitting
- Identify if this is a "leaf" component (no children), "branch" component (manages children), or "root" component (page-level orchestration)

Questions to answer:
- Does this component own any data fetching?
- Does this component manage any state, or is it purely presentational?
- Is this component reusable across multiple contexts, or specific to one page?

**Output:** Component responsibility statement with clear boundaries.

### Step 2: Categorize State

Identify all state the component needs and categorize it into the correct bucket. Different state categories require different management strategies.

| Category | Description | Tool |
|----------|-------------|------|
| **Server State** | Data from the server (API responses, database records) | React Query / SWR / Server Components |
| **UI State** | Visual state (open/closed, selected tab, hover) | useState / useReducer |
| **Form State** | Input values, validation, dirty/touched | React Hook Form / useActionState |
| **URL State** | State encoded in the URL (filters, pagination, search) | useSearchParams / nuqs |

For each piece of state:
- Name it explicitly
- Categorize it
- Identify its lifecycle (when is it created, when is it destroyed)
- Determine if it needs to be shared (lifted up) or can be local

**Anti-pattern check:** If server state is being duplicated into `useState`, that is almost always wrong. Server state should be managed by a server state library, not copied into UI state.

**Output:** State inventory table with categories and management tools.

### Step 3: Choose Composition Pattern

Select the right composition pattern based on the component's flexibility requirements.

| Pattern | When to Use | Example |
|---------|-------------|---------|
| **Props-based** | Simple, few variants, no need for flexible layout | `<Button variant="primary" size="lg">` |
| **Compound Components** | Multi-part component with shared implicit state | `<Tabs> <TabList> <Tab> ... </TabList> <TabPanels>` |
| **Slots / Children** | Flexible content injection without tight coupling | `<Card header={<Title />} footer={<Actions />}>` |
| **Render Props** | Maximum flexibility for rendering logic | `<DataTable renderRow={(row) => <CustomRow data={row} />}>` |
| **Headless / Hook** | Behavior without UI (let consumer decide rendering) | `useCombobox()` returns state + handlers, no JSX |

Decision criteria:
- How many layout variations does this component need? (few = props, many = slots/compound)
- Does the component need to share implicit state across parts? (yes = compound)
- Does the consumer need full control over rendering? (yes = headless/render props)
- Is this a design system primitive or an app-specific component? (primitive = more flexible pattern)

**Output:** Selected pattern with rationale.

### Step 4: Define Server vs Client Boundary

Determine which parts of the component tree are Server Components and which must be Client Components.

Guiding principle: **Push `'use client'` as far down the tree as possible.** Start with everything as a Server Component, then only mark the leaf nodes that need interactivity as client.

A component MUST be a Client Component if it:
- Uses `useState`, `useReducer`, `useEffect`, `useRef` with DOM interaction
- Has event handlers (`onClick`, `onChange`, `onSubmit`)
- Uses browser-only APIs (`window`, `document`, `localStorage`)
- Uses context (`useContext`)
- Uses third-party libraries that depend on client state

A component SHOULD be a Server Component if it:
- Only renders static content
- Fetches data that does not depend on client state
- Does not need interactivity
- Wraps client components with server-fetched data

Pattern: **Server Wrapper + Client Island**
```tsx
// ServerWrapper.tsx (Server Component)
async function ServerWrapper() {
  const data = await fetchData();
  return <ClientIsland initialData={data} />;
}

// ClientIsland.tsx ('use client')
function ClientIsland({ initialData }) {
  const [state, setState] = useState(initialData);
  // interactive behavior here
}
```

**Output:** Component tree diagram showing server/client boundaries.

### Step 5: Design Props API

Define the props interface for the component, following API design best practices.

- Name props clearly (boolean props should read as questions: `isOpen`, `hasError`, `isDisabled`)
- Prefer specific props over catch-all `style` or `className` props for design system components
- Use discriminated unions for mutually exclusive variants
- Make required props truly required, optional props truly optional
- Provide sensible defaults for optional props
- Include escape hatches for advanced usage (e.g., `asChild` pattern for polymorphism)

```typescript
interface ComponentProps {
  /** Required: what the component renders */
  children: React.ReactNode;
  /** Visual variant */
  variant: 'primary' | 'secondary' | 'ghost';
  /** Size preset */
  size?: 'sm' | 'md' | 'lg'; // default: 'md'
  /** Controlled open state */
  isOpen?: boolean;
  /** Callback when open state changes */
  onOpenChange?: (open: boolean) => void;
}
```

Validate the API by imagining 3 different usage scenarios. If the API feels awkward in any of them, redesign.

**Output:** TypeScript interface definition with JSDoc comments.

### Step 6: Plan Testing Approach

Design the testing strategy following Testing Library methodology: test user behavior, not implementation details.

- Identify the key user behaviors to test (what does the user DO with this component?)
- Write test descriptions in user-centric language ("user can open the dropdown by clicking the trigger")
- Plan query strategy: `getByRole` > `getByLabelText` > `getByText` > `getByTestId`
- Identify integration tests needed (component with its real children and context)
- Identify edge cases: error states, empty states, loading states, boundary values
- Plan accessibility tests: keyboard navigation, screen reader announcements

**Anti-pattern check:** No test should assert on:
- Internal state values
- CSS class names
- DOM structure details
- Number of renders
- Implementation-specific hooks

**Output:** Test plan with described scenarios and query strategies.

---

## Quality Criteria

- The component design must address all six steps before implementation begins
- State must be categorized — no "just use useState for everything"
- The server/client boundary must be intentional and documented
- The props API must be validated against at least 3 usage scenarios
- The testing plan must not contain implementation detail assertions

---

*Squad Apex — Component Design Task v1.0.0*

---

## Quality Gate

```yaml
gate:
  id: QG-component-design
  blocker: true
  criteria:
    - "All outputs listed in YAML header must be produced"
    - "Component responsibility must be clearly scoped (single responsibility)"
    - "State categorization must distinguish server, client, and URL state"
    - "Server/client boundary must be explicitly defined with 'use client' rationale"
    - "Props API must be fully typed with TypeScript interfaces"
    - "Testing approach must cover unit, integration, and accessibility scenarios"
  on_fail: "BLOCK — return to executor with specific gaps listed"
  on_pass: "Mark task complete, deliver outputs to handoff target"
```

---

## Handoff

| Field | Value |
|-------|-------|
| Delivers to | `@css-eng` or `@a11y-eng` |
| Artifact | Component design spec with responsibility definition, state model, composition pattern, and props API |
| Next action | Implement styling architecture and accessibility patterns for the designed component |
