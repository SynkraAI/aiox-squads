# Apex Squad — Frontend Ultra-Premium

> 15 agentes especializados com DNA de elite minds do frontend mundial.
> 84 tasks. 8 workflows. 7 discovery tools. 31 design presets.
> Handoff visivel entre agentes. Intelligence layer autonoma.
> Tudo que o usuario ve e toca: design system, componentes, animacoes,
> 3D/spatial, acessibilidade, performance, CSS, tipografia, cores, efeitos.

---

## TL;DR

```
@apex "o header ta quebrando no mobile"
```

Isso e TUDO que voce precisa dizer. Apex:
1. Escaneia o projeto (stack, estrutura, design patterns)
2. Classifica a intent (fix)
3. Seleciona o pipeline (*apex-fix)
4. Delega para o especialista certo (Josh @css-eng)
5. Josh se apresenta, resolve, sugere proximo passo
6. Voce decide: aceitar, continuar a chain, ou parar

**Zero fricao. Voce fala o que quer, Apex resolve.**

---

## Plataformas

| Plataforma | Stack |
|------------|-------|
| **Web** | Next.js 15+, React 19+, App Router, RSC-first |
| **Mobile** | React Native New Architecture, Expo SDK 52+ |
| **Spatial** | VisionOS, WebXR, Three.js, React Three Fiber |

---

## Agentes (15)

Organizados em 5 tiers. Cada agente tem DNA de uma referencia real do frontend mundial.

| Icon | Nome | ID | Tier | DNA Source | Especialidade |
|------|------|----|------|------------|---------------|
| ⚡ | Emil | `apex-lead` | Orchestrator | Emil Kowalski (Linear, Vercel) | Design Engineering Lead — roteia, coordena, aprova |
| 🏛️ | Arch | `frontend-arch` | T1 | Lee Robinson (Vercel VP) | Arquitetura frontend, RSC, monorepo |
| 🎨 | Ahmad | `interaction-dsgn` | T2 | Ahmad Shadeed (Defensive CSS) | UX patterns, interaction design |
| 🎯 | Diana | `design-sys-eng` | T2 | Diana Mounter (GitHub DS) | Design system, tokens, temas |
| 🎭 | Josh | `css-eng` | T3 | Josh Comeau (CSS for JS Devs) | CSS architecture, layout, responsive |
| ⚛️ | Kent | `react-eng` | T3 | Kent C. Dodds (Epic React) | React components, hooks, testing |
| 📱 | Krzysztof | `mobile-eng` | T3 | Krzysztof Magiera (Reanimated) | React Native, gestures, worklets |
| 🌐 | Fernando | `cross-plat-eng` | T3 | Fernando Rojo (Solito, Moti) | Cross-platform, universal components |
| 🌌 | Paul | `spatial-eng` | T3 | Paul Henschel (R3F, Drei) | 3D, WebXR, VisionOS, shaders |
| 🎬 | Matt | `motion-eng` | T4 | Matt Perry (Framer Motion) | Spring animations, choreography |
| ♿ | Sara | `a11y-eng` | T4 | Sara Soueidan (Practical A11y) | WCAG, keyboard, screen readers |
| 🚀 | Addy | `perf-eng` | T4 | Addy Osmani (Google Chrome) | Core Web Vitals, bundle, loading |
| 👁️ | Andy | `qa-visual` | T5 | Andy Bell (CUBE CSS) | Visual regression, cross-browser |
| 📋 | Michal | `qa-xplatform` | T5 | Michal Pierzchala (Callstack) | Cross-platform device testing |

### Auto-Profile (baseado no seu projeto)

| Profile | Agentes ativos | Quando |
|---------|---------------|--------|
| `full` (15) | Todos | Monorepo web + mobile + spatial |
| `web-next` (10) | Sem mobile/spatial/cross-plat | Next.js projects |
| `web-spa` (8) | Sem arch/mobile/spatial/ds/cross-plat | React + Vite SPA |
| `minimal` (4) | apex-lead, css-eng, react-eng, a11y-eng | Quick fixes |

Detectado automaticamente via `package.json`. Sem configuracao manual.

---

## Handoff entre Agentes

Toda delegacao e **visivel**. Voce sempre sabe qual agente esta trabalhando e por que.

```
User: "o header ta quebrando no mobile"

Emil: Isso e CSS responsivo — delegando para 🎭 Josh (@css-eng).
      Ele e o especialista em layout algorithms e stacking contexts.

🎭 Josh aqui. O header usa flexbox sem flex-wrap — quebra abaixo de 375px.
   [analisa, corrige]

🎭 Josh — concluido.
   1 arquivo modificado (Header.tsx). Typecheck PASS. Lint PASS.

   Sugiro verificar com ♿ Sara (@a11y-eng) — touch targets mudaram.

   1. Verificar a11y com Sara
   2. Rodar suggestions no Header.tsx
   3. Done

User: "1"

🎭 Josh: Delegando para ♿ Sara (@a11y-eng).

♿ Sara aqui. Touch targets 38x38px — abaixo do minimo 44x44.
   [corrige padding]

♿ Sara — concluido. 1 arquivo. Typecheck PASS.
   1. Rodar suggestions  2. Done
```

### Chains comuns

| Situacao | Sequencia |
|----------|-----------|
| Fix CSS | Josh → Sara (a11y) |
| Nova animacao | Matt → Sara (reduced-motion) → Addy (60fps) |
| Novo componente | Kent → Josh (estilo) → Matt (motion) → Sara (a11y) |
| Fix responsivo | Josh → Andy (cross-browser) |
| Design system | Diana → Josh (CSS tokens) → Andy (visual regression) |
| Dark mode | Diana → Sara (contraste) → Andy (visual test) |
| Analise visual | Emil (analyze) → Ahmad (UX) → Josh ou Matt |

---

## Comandos

### Entrada Natural (recomendado)

```
@apex {qualquer descricao em linguagem natural}
```

### Pipeline

| Comando | O que faz |
|---------|-----------|
| `*apex-go {desc}` | Pipeline completo 7 fases (autonomo, pausa em 6 checkpoints) |
| `*apex-step {desc}` | Pipeline guiado (pausa apos cada fase) |
| `*apex-quick {desc}` | Pipeline rapido 3 fases (specify → implement → ship) |
| `*apex-fix {desc}` | Fix single-agent (route → execute → verify) |
| `*apex-resume` | Retomar pipeline pausado/crashado |
| `*apex-status` | Status do pipeline atual |
| `*apex-abort` | Cancelar pipeline |
| `*apex-pivot` | Mudar direcao mid-pipeline |

### Discovery (7 tools)

| Comando | O que mapeia |
|---------|-------------|
| `*discover-components` | Componentes, deps, orphans, testes, health score |
| `*discover-design` | Tokens, violacoes, paleta, DS score |
| `*discover-routes` | Rotas, orphan routes, dead routes, SEO gaps |
| `*discover-dependencies` | Outdated, vulneraveis, pesadas, unused |
| `*discover-motion` | Animacoes, CSS→spring violations, reduced-motion |
| `*discover-a11y` | WCAG violations, keyboard traps, labels, contraste |
| `*discover-performance` | Lazy loading, imagens, re-renders, CWV risks |

Cada discovery produz um **health score 0-100** e sugere o proximo passo automaticamente.

### Visual Analysis

| Comando | Quando |
|---------|--------|
| `*apex-analyze` | 1 screenshot — analise 8 dimensoes com score |
| `*apex-compare` | 2 screenshots — comparacao lado a lado com delta |
| `*apex-consistency` | 3+ screenshots — auditoria cross-page |

**8 dimensoes:** Layout, Tipografia, Cores, Composicao, Interacao, Motion, Acessibilidade, Performance.

### Quality & Audit

| Comando | O que faz |
|---------|-----------|
| `*apex-review` | Code review multi-agente (patterns, arch, perf, a11y) |
| `*apex-dark-mode` | Auditoria dark mode completa |
| `*apex-critique` | Design critique com principios formais (Gestalt, hierarquia) |
| `*apex-export-tokens {fmt}` | Exportar tokens (Figma, Style Dictionary, CSS, Tailwind) |
| `*apex-integration-test` | Setup integration tests para interacoes compostas |
| `*apex-refactor {component}` | Refactoring seguro (5 fases com baseline tests) |

### Style Presets (31)

| Comando | O que faz |
|---------|-----------|
| `*apex-inspire` | Navegar catalogo de 31 presets |
| `*apex-transform --style {id}` | Aplicar estilo completo com 1 comando |

### Outros

| Comando | O que faz |
|---------|-----------|
| `*apex-scan` | Scan do projeto (stack, estrutura, convencoes) |
| `*apex-suggest` | Deteccao proativa de issues |
| `*apex-audit` | Diagnostico completo do squad para o projeto |
| `*apex-agents` | Listar agentes ativos no profile atual |

---

## Discovery Tools — Raio-X do Projeto

**7 discovery tools** escaneiam o codebase real ANTES de qualquer acao. O squad nunca chuta — diagnostica.

### `*discover-components`
Inventaria TODOS os componentes React:
- Component map (nome, tipo, LOC, imports, quem importa)
- Dependency tree e componentes hub (alto impacto)
- Orphans (exportados mas nunca importados)
- God components (>200 LOC + >5 hooks)
- Health score 0-100

### `*discover-design`
Mapeia o design system REAL (o que esta no codigo):
- Token inventory (CSS vars, Tailwind config, theme objects)
- Violacoes (hardcoded que deveria ser token)
- Near-duplicates (cores com <5% distancia HSL)
- DS Score 0-100 (solid/emerging/adhoc)

### `*discover-routes`
Mapeia TODAS as rotas/paginas:
- Route map (path, component, layout, params, guards)
- Orphan routes (nenhum nav aponta)
- Dead routes (componente nao existe)
- SEO gaps (sem title, meta, og:image)

### `*discover-dependencies`
Audita todas as dependencias:
- Outdated (major version atras)
- Vulneraveis (npm audit integrado)
- Pesadas (com alternativas sugeridas)
- Unused (safe to remove)

### `*discover-motion`
Inventaria TODAS as animacoes:
- Animation map (componente, tipo, lib, trigger)
- CSS transitions que deveriam ser springs
- Missing prefers-reduced-motion
- Non-GPU animations

### `*discover-a11y`
Scan estatico de acessibilidade:
- Missing alt, form labels, ARIA misuse
- Keyboard traps, heading structure
- Contraste estimado, touch targets

### `*discover-performance`
Analise estatica de performance:
- Lazy loading gaps, image audit
- Re-render risks (inline objects, context without slice)
- Bundle risks, third-party cost
- Core Web Vitals risks (LCP, INP, CLS)

---

## Style Presets — 31 Estilos com 1 Comando

```
@apex "quero estilo Apple liquid glass"
```

| Categoria | Presets |
|-----------|--------|
| **Apple** | Liquid Glass, HIG Classic, visionOS Spatial |
| **Google** | Material 3, Material You |
| **Tech** | Linear, Vercel, Stripe, Notion, GitHub, Spotify, Discord |
| **Movements** | Glassmorphism, Neumorphism, Brutalist, Minimalist, Y2K, Claymorphism, Aurora |
| **Industry** | Healthcare, Fintech, SaaS, E-commerce, Education |
| **Dark** | Dark Elegant, OLED Black, Nord |
| **Experimental** | Neubrutalism, Cyberpunk, Organic, Swiss Grid |

Cada preset define tokens completos: cores, tipografia, spacing, radius, shadows, motion.

---

## Visual Analysis — Manda um Print

| Input | Apex faz |
|-------|----------|
| 1 print | Analise profunda em 8 dimensoes, score 0-100, opcoes |
| 2 prints | Comparacao lado a lado com delta por dimensao |
| 3+ prints | Auditoria de consistencia cross-page |

**Print interno (do projeto):**
1. MANTER — esta bom
2. APERFEICOAR — melhorar (gera fix list)
3. TRANSFORMAR — aplicar preset diferente
4. COMPARAR — lado a lado com referencia

**Print externo (outro app):**
1. REPLICAR — recriar no projeto
2. INSPIRAR — adaptar ao seu estilo
3. COMPARAR — com implementacao atual
4. ELEMENTOS — extrair tokens especificos

---

## Intelligence Layer

### Intent Chaining — "E depois?"

Apos CADA operacao, Apex sugere o proximo passo logico:

```
🎭 Josh — concluido. 1 arquivo. Typecheck PASS.

1. Rodar suggestions no arquivo modificado
2. Verificar a11y com Sara
3. Done

O que prefere?
```

17 intent chains condicionais cobrem todos os cenarios: fix, quick, pipeline, discover, analyze, compare, transform, inspire, audit, consistency.

### Smart Defaults — Parar de perguntar o obvio

| Se o squad ja sabe... | Nao pergunta |
|----------------------|--------------|
| So tem 1 componente no escopo | "Qual componente?" |
| Escopo e 1 arquivo | "Pipeline completo ou quick?" |
| Domain mapeia para 1 agente | "Qual agente?" |
| Print veio com "quero assim" | "Interno ou externo?" |
| Healthcare project | Prioriza acessibilidade |

### Context Memory — 10 Caches Persistentes

| Cache | O que guarda |
|-------|-------------|
| Scan | Stack, framework, styling, design language |
| Components | Inventario, orphans, health score |
| Design | Tokens, violacoes, DS score |
| Routes | Route map, orphans, SEO gaps |
| Dependencies | Outdated, heavy, unused |
| Motion | Animation map, veto violations |
| A11y | Issues por categoria, worst offenders |
| Performance | CWV risks, lazy gaps, image issues |
| Visual History | Analises anteriores, estilos aprovados/rejeitados |
| User Prefs | Pipeline preferido, style direction, prioridades |

---

## Quality Gates (10)

Dez gates bloqueiam features antes de ship. TODOS sao blockers.

| Gate | Nome | Owner | Fase |
|------|------|-------|------|
| QG-AX-001 | Token Compliance | @design-sys-eng | Design |
| QG-AX-002 | Spec Completeness | @interaction-dsgn | Design |
| QG-AX-003 | Architecture | @frontend-arch | Build |
| QG-AX-004 | Behavior & States | @react-eng | Build |
| QG-AX-005 | Motion & Reduced-Motion | @motion-eng | Build |
| QG-AX-006 | A11y (WCAG AA) | @a11y-eng | Build |
| QG-AX-007 | Performance Budgets | @perf-eng | Build |
| QG-AX-008 | Visual Regression | @qa-visual | Ship |
| QG-AX-009 | Cross-Platform | @qa-xplatform | Ship |
| QG-AX-010 | Final Review (NON-WAIVABLE) | @apex-lead | Ship |

### Veto Conditions

67+ veto conditions com `available_check` + `on_unavailable`. Cobertura 100%.

**Adaptive enforcement:** Se uma ferramenta nao existe no projeto (Chromatic, Storybook, Playwright), o veto faz SKIP com warning em vez de BLOCK. Sem false positives.

---

## Pipeline (7 Fases)

```
Specify → Design → Architect → Implement → Polish → QA → Ship
  CP-01    CP-02    CP-03                   CP-05        CP-04/06
```

- **6 user checkpoints** (CP-01 a CP-06) — decisoes criativas nunca sao automatizadas
- **10 quality gates** — blockers reais, nao sugestoes
- **State persistence** — pipeline pode pausar, crashar, e ser retomado
- **2 modos:** autonomo (*apex-go) ou guiado (*apex-step)

---

## Filosofia

### 1. Feel > Look
Interface que SENTE certo vale mais que interface que PARECE certa.

### 2. Spring > Ease
`transition: all 0.2s ease` esta PROIBIDO. Springs tem massa, stiffness, damping.

| Preset | Stiffness | Damping | Mass | Uso |
|--------|-----------|---------|------|-----|
| `gentle` | 120 | 14 | 1 | Modais, drawers, transicoes |
| `responsive` | 300 | 20 | 1 | Botoes, toggles, accordions |
| `snappy` | 500 | 25 | 0.8 | Micro-interacoes, feedback |
| `bouncy` | 200 | 10 | 1 | Celebracoes, success states |

### 3. Token Authority
Nenhum valor hardcoded. Tudo vive em tokens.

### 4. 4px Grid Is Law
Todo spacing e multiplo de 4px. Sem excecoes.

### 5. Accessibility Is Not Optional
WCAG 2.2 AA e o piso. axe-core: 100. Touch targets: 44x44px minimo.

### 6. Cross-Platform Parity
Mesma qualidade em Web, Mobile e Spatial.

---

## Performance Standards

### Web
| Metrica | Target |
|---------|--------|
| LCP | < 1.2s |
| INP | < 200ms |
| CLS | < 0.1 |
| First Load JS | < 80KB gzipped |
| Animation FPS | >= 60fps |

### Mobile
| Metrica | Target |
|---------|--------|
| Cold startup | < 1s |
| UI/JS thread FPS | >= 60fps |
| ANR rate | 0% |

---

## Estrutura do Squad

```
squads/apex/
├── agents/          # 14 agent definitions
├── tasks/           # 84 executable tasks
├── workflows/       # 8 multi-phase workflows
├── checklists/      # 28 quality checklists
├── templates/       # 13 document templates
├── data/            # 9 data files (tokens, presets, intelligence)
├── config/          # Squad configuration
├── squad.yaml       # Manifest
├── CLAUDE.md        # Project integration
└── README.md        # This file
```

---

## Git Authority

Agentes Apex podem: `git add`, `git commit`, `git status`, `git diff`, editar arquivos, rodar testes.

Agentes Apex NAO podem: `git push`, `gh pr create`, gerenciar CI/CD — delegar para `@devops`.

---

## Exemplos de Uso

```
@apex "o header ta quebrando no mobile"           → *apex-fix → Josh
@apex "adiciona animacao no card"                  → *apex-fix → Matt
@apex "cria um componente de stats"                → *apex-quick → Kent + Josh
@apex "redesenha a pagina de servicos"             → *apex-go → pipeline completo
@apex "como ta a acessibilidade?"                  → *discover-a11y
@apex "quero estilo Apple liquid glass"            → *apex-transform
@apex "dependencias desatualizadas?"               → *discover-dependencies
@apex [screenshot do app]                          → *apex-analyze (8 dimensoes)
@apex [screenshot do Stripe]                       → replicar/inspirar/comparar
@apex [5 screenshots de paginas]                   → *apex-consistency
```

---

*Apex Squad v1.1.0 — "Every pixel is a decision." — Emil ⚡*
