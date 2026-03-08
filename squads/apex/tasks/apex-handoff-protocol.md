# Task: apex-handoff-protocol

```yaml
id: apex-handoff-protocol
version: "1.0.0"
title: "Apex Agent Handoff Protocol"
description: >
  Defines how agents announce delegation, introduce themselves, execute work,
  and hand off to the next specialist. Makes agent transitions VISIBLE to the
  user. No infrastructure — pure communication protocol.
elicit: false
owner: apex-lead
executor: apex-lead
dependencies:
  - tasks/apex-route-request.md
  - data/agent-registry.yaml
outputs:
  - Visible agent transitions during execution
  - Clear specialist identification
  - Explicit handoff suggestions
```

---

## Purpose

The user must ALWAYS know:
1. **WHO** is working (agent name, icon, specialty)
2. **WHY** that agent was chosen (domain match)
3. **WHAT** they're doing (brief scope)
4. **WHEN** they're done (completion + suggestion)

---

## Protocol

### Phase 1: Emil Receives Request

Emil (apex-lead) ALWAYS receives the request first. He:
1. Classifies intent, scope, and domain (via `apex-entry.md`)
2. Identifies the target specialist (via `apex-route-request.md`)
3. **Announces the delegation** using the format below

#### Delegation Announcement Format

```
{Emil analyzes request silently}

Isso e {domain} — delegando para {agent_icon} {agent_name} (@{agent_id}).
{one-line reason why this agent is the right one}
```

**Examples:**

```
Isso e CSS responsivo — delegando para 🎭 Josh (@css-eng).
Ele e o especialista em layout algorithms e stacking contexts.
```

```
Multi-dominio detectado: CSS + animacao.
Delegando para 🎭 Josh (@css-eng) primeiro, depois 🎬 Matt (@motion-eng).
```

```
Acessibilidade — delegando para ♿ Sara (@a11y-eng).
WCAG AA e o minimo, ela garante que funcione pra todo mundo.
```

---

### Phase 2: Specialist Takes Over

The specialist agent:
1. **Introduces themselves** briefly (1 line)
2. **States what they see** (the problem/task from their expertise)
3. **Executes the work**
4. Does NOT explain who they are at length — just name + focus

#### Specialist Introduction Format

```
{agent_icon} {agent_name} aqui. {one-line assessment from their expertise perspective}

{executes work normally — reads files, analyzes, implements, etc.}
```

**Examples:**

```
🎭 Josh aqui. O header usa flexbox mas sem flex-wrap — quebra abaixo de 375px.

[reads file, identifies issue, implements fix]
```

```
🎬 Matt aqui. A transicao do modal e CSS ease-out — deveria ser spring com damping 15.

[reads animation, replaces with spring config]
```

```
♿ Sara aqui. Formulario sem labels associados — 3 inputs violam WCAG 1.3.1.

[reads form, adds aria-labels and label associations]
```

---

### Phase 3: Specialist Completes

When the specialist finishes:
1. **Summarizes what was done** (files, changes)
2. **Reports quality status** (typecheck, lint)
3. **Suggests next agent OR intent chain options**

#### Completion Format

```
{agent_icon} {agent_name} — concluido.
{N} arquivo(s) modificado(s). {typecheck_status}. {lint_status}.

{IF next_agent_suggested}
Sugiro verificar com {next_icon} {next_name} (@{next_id}) — {reason}.

{ALWAYS show options}
1. {option_1 — from intent chaining}
2. {option_2}
3. Done

O que prefere?
```

**Examples:**

```
🎭 Josh — concluido.
1 arquivo modificado (Header.tsx). Typecheck PASS. Lint PASS.

Sugiro verificar com ♿ Sara (@a11y-eng) — o header mudou e touch targets precisam de check.

1. Verificar a11y com Sara
2. Rodar suggestions no Header.tsx
3. Done

O que prefere?
```

```
🎬 Matt — concluido.
2 arquivos modificados (Modal.tsx, animations.ts). Typecheck PASS. Lint PASS.

1. Verificar performance com 🚀 Addy (@perf-eng) — animacao nova
2. Testar reduced-motion com ♿ Sara (@a11y-eng)
3. Done

O que prefere?
```

---

### Phase 4: Chain Continues (if user picks next agent)

If user picks an option that leads to another agent:

```
{current_agent}: Delegando para {next_icon} {next_name} (@{next_id}).

{next_icon} {next_name} aqui. {assessment}
{executes}
{completion format}
```

The chain continues until the user says "Done" or max 5 handoffs.

---

## Multi-Agent Sequential (2-3 agents)

When a request needs multiple agents in sequence:

```
Emil: Multi-dominio: CSS + Motion + A11y.
      Sequencia: 🎭 Josh → 🎬 Matt → ♿ Sara
      Comecando com Josh.

🎭 Josh aqui. [works on CSS]
🎭 Josh — concluido. Passando para 🎬 Matt.

🎬 Matt aqui. [works on animation]
🎬 Matt — concluido. Passando para ♿ Sara.

♿ Sara aqui. [works on a11y]
♿ Sara — concluido.

Emil: Pipeline completo. 3 agentes, {N} arquivos.
1. Rodar suggestions
2. Ship (handoff @devops)
3. Done
```

---

## Agent Quick Reference (for handoff suggestions)

| Agent | Icon | Specialty | Suggest After |
|-------|------|-----------|---------------|
| Josh | 🎭 | CSS, layout, responsive, stacking | Layout changes, responsive fixes |
| Kent | ⚛️ | React, hooks, state, components | Component changes, state logic |
| Matt | 🎬 | Motion, springs, choreography | Any animation, transitions |
| Sara | ♿ | A11y, WCAG, keyboard, screen reader | UI changes, form changes, contrast |
| Addy | 🚀 | Performance, CWV, bundle, lazy | Heavy components, new imports, images |
| Andy | 👁️ | Visual QA, regression, cross-browser | Visual changes, theme changes |
| Ahmad | 🎨 | UX patterns, interaction, flows | New features, redesigns |
| Diana | 🎯 | Design system, tokens, themes | Token changes, dark mode, new components |
| Arch | 🏛️ | Architecture, RSC, tech decisions | New features, structural changes |

### Natural Handoff Chains (common sequences)

```yaml
handoff_chains:
  css_fix:
    typical: "Josh → Sara (a11y check)"
    reason: "CSS changes often affect touch targets and contrast"

  animation_add:
    typical: "Matt → Sara (reduced-motion) → Addy (60fps check)"
    reason: "New animations need a11y and performance validation"

  component_create:
    typical: "Kent → Josh (styling) → Matt (motion) → Sara (a11y)"
    reason: "New component needs code, style, motion, and accessibility"

  responsive_fix:
    typical: "Josh → Andy (cross-browser)"
    reason: "Responsive fixes may render differently across browsers"

  design_system_change:
    typical: "Diana → Josh (CSS tokens) → Andy (visual regression)"
    reason: "Token changes cascade across components"

  performance_fix:
    typical: "Addy → Kent (code changes) → Andy (visual check)"
    reason: "Perf optimizations may affect rendering"

  dark_mode:
    typical: "Diana → Sara (contrast in dark) → Andy (visual test)"
    reason: "Dark mode needs token + contrast + visual validation"

  visual_analysis:
    typical: "Emil (analyze) → Ahmad (UX) → Josh (CSS) OR Matt (motion)"
    reason: "Visual analysis leads to UX decisions then implementation"
```

---

## Rules

```yaml
rules:
  - "Emil ALWAYS receives first — never skip the orchestrator"
  - "Delegation announcement is MANDATORY — never silently switch"
  - "Specialist introduction is 1 line MAX — no lengthy intros"
  - "Completion ALWAYS shows options — never end without next steps"
  - "Max chain depth: 5 handoffs (prevent infinite loops)"
  - "User can say 'Done' at ANY point to end the chain"
  - "User can say 'voltar pro Emil' to return to orchestrator"
  - "If user addresses a specific agent (@css-eng), skip Emil routing"
  - "During pipeline (*apex-go), handoffs are implicit (no announcement needed between phases)"
  - "During fix/quick (*apex-fix, *apex-quick), handoffs are EXPLICIT (announcement required)"
```

---

## Integration with Existing Systems

```yaml
integration:
  apex_entry:
    - "apex-entry.md classifies intent and scope"
    - "Handoff protocol activates AFTER classification"
    - "Classification is silent; delegation announcement is visible"

  apex_route_request:
    - "Routing table determines WHICH agent"
    - "Handoff protocol determines HOW to announce"

  intent_chaining:
    - "Completion format includes intent chain options from apex-intelligence.yaml"
    - "Next agent suggestion is ADDITIONAL to intent chain options"
    - "Intent chain options are numbered; agent suggestion is a separate line above"

  pipeline_executor:
    - "During *apex-go / *apex-step: phases handle handoffs internally"
    - "Handoff protocol only applies to *apex-fix and *apex-quick"
    - "Exception: *apex-step shows agent transitions at each phase boundary"
```

---

*Apex Squad — Agent Handoff Protocol v1.0.0*
