# Apex Squad — Autonomous Frontend Intelligence

## Single Entry Point

**O usuario NAO precisa saber comandos ou nomes de agentes.** Basta descrever o que quer em linguagem natural.

```
@apex {qualquer descricao em linguagem natural}
```

Apex automaticamente:
1. **Escaneia o projeto** (stack, estrutura, design patterns) via `apex-scan`
2. **Classifica a intent** (fix, improve, create, redesign, audit, question)
3. **Seleciona o pipeline** (*apex-fix, *apex-quick, *apex-go, ou resposta direta)
4. **Roteia para os agentes certos** (baseado no profile detectado)
5. **Apresenta o plano** e espera confirmacao
6. **Executa e sugere melhorias** apos conclusao

### Exemplos de uso natural

| O usuario diz | Apex faz |
|---------------|----------|
| "o header ta quebrando no mobile" | *apex-fix → @css-eng |
| "adiciona animacao no card" | *apex-fix → @motion-eng |
| "cria um componente de stats com grafico" | *apex-quick → @react-eng + @css-eng |
| "redesenha a pagina inteira de servicos" | *apex-go → full pipeline |
| "como ta a acessibilidade?" | *apex-audit (sem pipeline) |
| "quais componentes usam motion?" | Resposta direta (sem pipeline) |

**O usuario SEMPRE mantem controle total** — Apex apresenta plano e espera "sim" antes de executar.

---

## Agent Handoff — "Quem ta trabalhando?"

**Toda delegacao e VISIVEL.** Voce sempre sabe qual agente esta trabalhando e por que.

### Fluxo de handoff

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

   O que prefere?

User: "1"

🎭 Josh: Delegando para ♿ Sara (@a11y-eng).

♿ Sara aqui. Touch targets no header: 38x38px — abaixo do minimo 44x44.
   [corrige padding]
♿ Sara — concluido.
   1 arquivo modificado. Typecheck PASS.

   1. Rodar suggestions
   2. Done

   O que prefere?
```

### Regras do handoff

- Emil SEMPRE recebe primeiro — nunca pula o orchestrator
- Delegacao e ANUNCIADA — nunca troca silenciosamente
- Especialista se apresenta em 1 LINHA — sem introducoes longas
- Conclusao SEMPRE mostra opcoes — nunca termina sem proximo passo
- Max 5 handoffs encadeados
- "Done" encerra a chain a qualquer momento

### Chains comuns entre agentes

| Situacao | Sequencia tipica |
|----------|-----------------|
| Fix CSS | Josh → Sara (a11y check) |
| Nova animacao | Matt → Sara (reduced-motion) → Addy (60fps) |
| Novo componente | Kent → Josh (estilo) → Matt (motion) → Sara (a11y) |
| Fix responsivo | Josh → Andy (cross-browser) |
| Design system | Diana → Josh (CSS tokens) → Andy (visual regression) |
| Dark mode | Diana → Sara (contraste) → Andy (visual test) |

---

## Intent Chaining — "E depois?"

Apos CADA operacao, Apex sugere o proximo passo logico baseado no resultado:

```
Fix aplicado. 1 arquivo modificado. typecheck PASS.

Proximo passo:
  1. Rodar suggestions no arquivo modificado
  2. Fazer outro fix
  3. Done

O que prefere? (1/2/3)
```

**Como funciona:**
- Apos *apex-fix → sugere suggestions, outro fix, ou done
- Apos *apex-quick → sugere suggestion scan, deploy, ou outro quick
- Apos *apex-go → sugere ship, polish cycle, ou revisar (baseado no QA verdict)
- Apos *discover-components → sugere limpar orphans, adicionar testes, ou discover-design
- Apos *discover-design → sugere corrigir violacoes, discover-components, ou done
- Apos *apex-suggest → sugere aplicar suggestion #1, batch fix, ou ignorar

**Regras:**
- Usuario escolhe por numero (1/2/3) ou digita naturalmente
- "done" / "pronto" / "so isso" → encerra a chain
- Max 5 operacoes encadeadas
- NUNCA auto-executa — sempre espera escolha do usuario

Ver `data/apex-intelligence.yaml` para regras completas.

---

## Visual Analysis — "Manda um print que eu analiso"

**O usuario pode mandar qualquer screenshot/print** e Apex analisa tudo automaticamente.

### Fluxo automatico por quantidade de imagens

| Input | Apex faz |
|-------|----------|
| 1 print | `*apex-analyze` — analise profunda em 8 dimensoes com score |
| 2 prints | `*apex-compare` — comparacao lado a lado com delta |
| 3+ prints | `*apex-consistency` — auditoria de consistencia cross-page |

### 8 Dimensoes de Analise

Cada print e analisado em: **Layout, Tipografia, Cores, Composicao, Interacao, Motion, Acessibilidade, Performance.** Cada dimensao recebe score 0-100.

### Opcoes apos analise

**Print interno (do projeto):**
1. MANTER — esta bom
2. APERFEICOAR — melhorar o que tem (gera fix list)
3. TRANSFORMAR — aplicar estilo diferente (preset catalog)
4. COMPARAR — colocar lado a lado com referencia

**Print externo (outro app/referencia):**
1. REPLICAR — recriar esse design no projeto
2. INSPIRAR — usar como base mas adaptar
3. COMPARAR — comparar com implementacao atual
4. ELEMENTOS — extrair apenas tokens especificos (cores, fontes, etc.)

### Exemplos

```
User: [envia print do app]
Apex: Analise em 8 dimensoes, score 72/100, 3 melhorias sugeridas.
      1. Aperfeicoar  2. Transformar  3. Comparar  4. Done

User: [envia print do Stripe]
Apex: Referencia externa detectada. Score 94/100.
      1. Replicar  2. Inspirar  3. Comparar com meu app  4. Extrair tokens

User: [envia 5 prints de paginas diferentes]
Apex: Consistency Score 68/100. 12 inconsistencias (4 HIGH).
      1. Padronizar tudo  2. So criticas  3. Criar design system
```

**O usuario SEMPRE escolhe** — Apex NUNCA auto-executa apos analise.

---

## Auto-Activation Rules

This squad activates automatically when the user's request matches ANY frontend domain below. No manual activation needed.

**Trigger keywords (case-insensitive):**
- CSS, layout, flexbox, grid, spacing, z-index, overflow, responsive, typography, font
- React, component, hook, state, props, JSX, TSX, render
- animation, transition, spring, motion, Framer Motion, animate, hover effect
- design system, token, theme, dark mode, color variable, Figma
- accessibility, a11y, WCAG, screen reader, keyboard navigation, focus, ARIA, contrast
- performance, LCP, INP, CLS, bundle size, Core Web Vitals, lighthouse, loading
- visual regression, pixel, screenshot test, looks wrong, analisa esse print, olha esse app, quero assim, faz igual, compara, referencia visual
- mobile, React Native, iOS, Android, Expo, gesture, haptic
- 3D, Three.js, R3F, WebXR, VisionOS, spatial, shader
- cross-platform, universal component, platform parity

**Do NOT activate for:** git push, PR creation, CI/CD, backend API, database, product requirements, story creation, epic management. Redirect those to the appropriate AIOS agent (@devops, @dev, @data-engineer, @pm, @sm).

---

## Dynamic Project Scanner

**NUNCA hardcodar o projeto.** Na ativacao, Apex escaneia automaticamente:

### O que o scanner detecta

| Categoria | Detecta |
|-----------|---------|
| **Framework** | Next.js, Vite, Expo, CRA (de package.json) |
| **UI** | React, React Native, versao |
| **Styling** | Tailwind, styled-components, CSS Modules, Sass |
| **Animation** | Framer Motion, React Spring, GSAP |
| **Testing** | Vitest, Jest, Playwright, Testing Library |
| **3D** | Three.js, R3F |
| **Icons** | Lucide, Heroicons, Phosphor |
| **State** | Zustand, Jotai, Redux, Context |
| **Estrutura** | Monorepo vs single-app, quantidade de componentes/rotas |
| **Design language** | Glass morphism, Material, Flat, Custom (de CSS vars) |
| **Convencoes** | Naming, file org, import style |

### Profile Selection (auto-detectado)

```
IF monorepo com web + mobile:     profile = "full" (15 agentes)
ELIF react-native OR expo:         profile = "full"
ELIF next em dependencies:         profile = "web-next" (10 agentes)
ELIF react + vite:                 profile = "web-spa" (8 agentes)
ELSE:                              profile = "minimal" (4 agentes)
```

### Profile → Active Agents

| Profile | Agents | Use Case |
|---------|--------|----------|
| `full` | All 15 | Monorepo cross-platform (Next.js + RN + Spatial) |
| `web-next` | apex-lead, frontend-arch, interaction-dsgn, design-sys-eng, css-eng, react-eng, motion-eng, a11y-eng, perf-eng, qa-visual | Next.js App Router projects |
| `web-spa` | apex-lead, interaction-dsgn, css-eng, react-eng, motion-eng, a11y-eng, perf-eng, qa-visual | React + Vite SPA |
| `minimal` | apex-lead, css-eng, react-eng, a11y-eng | Quick fixes, single components |

**IMPORTANT:** Only route requests to agents active in the current profile. If a request needs an inactive agent, inform the user and suggest upgrading the profile.

O scanner roda automaticamente (silent) na ativacao e pode ser executado manualmente com `*apex-scan` para ver o relatorio completo.

---

## Routing Table (Quick Reference)

| Request Domain | Route To | Example |
|----------------|----------|---------|
| CSS / layout / responsive / Tailwind | `@css-eng` | "fix the header layout on mobile" |
| React component / hooks / state | `@react-eng` | "add loading state to the form" |
| Animation / spring / motion | `@motion-eng` | "make the modal entrance smoother" |
| Accessibility / keyboard / contrast | `@a11y-eng` | "audit the schedule form for a11y" |
| Performance / loading / bundle | `@perf-eng` | "why is the page loading slow?" |
| UX pattern / user flow / states | `@interaction-dsgn` | "redesign the confirmation screen" |
| Visual QA / looks wrong | `@qa-visual` | "the card looks different than before" |
| Component inventory / orphans / deps | `*discover-components` | "quais componentes existem?" |
| Design system / tokens / cores | `*discover-design` | "como ta o design system?" |
| Route map / orphan routes / SEO | `*discover-routes` | "quais rotas tem?" |
| Dependency health / outdated | `*discover-dependencies` | "dependencias desatualizadas?" |
| Animation inventory / springs | `*discover-motion` | "como tao as animacoes?" |
| Accessibility scan / WCAG | `*discover-a11y` | "ta acessivel?" |
| Performance / lazy / images | `*discover-performance` | "ta rapido?" |
| Screenshot/print analysis | `*apex-analyze` | "analisa esse print" |
| Compare 2 designs | `*apex-compare` | "compara com esse app" |
| Multi-page consistency | `*apex-consistency` | "ta consistente?" |
| Code review frontend | `*apex-review` | "revisa esse codigo" |
| Dark mode issues | `*apex-dark-mode` | "dark mode ta quebrando" |
| Design critique | `*apex-critique` | "critica esse design" |
| Export tokens | `*apex-export-tokens` | "exporta tokens pro Figma" |
| Integration tests | `*apex-integration-test` | "testa o fluxo do modal" |
| Refactor component | `*apex-refactor` | "refatora esse god component" |
| New feature (multi-domain) | Full pipeline | "add a patient dashboard" |

### Auto-Routing (scope detection)

| Escopo | Auto-seleciona |
|--------|----------------|
| 1 arquivo, 1 dominio | `*apex-fix` → 1 agente |
| 2-3 arquivos, mesmo dominio | `*apex-fix` → 1 agente |
| 3-10 arquivos, multi-dominio | `*apex-quick` → 2-3 agentes |
| Feature nova, 10+ arquivos | `*apex-go` → pipeline completo |
| Cross-platform (web + mobile) | `*apex-go` → pipeline completo |

---

## Proactive Suggestions

Apos CADA operacao (fix, quick, pipeline), Apex escaneia os arquivos modificados e o contexto ao redor para detectar problemas que o usuario pode nao ter percebido.

**O que detecta:**

| Categoria | Exemplos |
|-----------|----------|
| A11y | Contraste baixo, alt text faltando, form sem label, keyboard nav |
| Performance | Imagens sem lazy load, code splitting faltando, re-renders |
| CSS | Cores hardcoded, spacing fora da escala, z-index chaos |
| Motion | CSS transition onde deveria ser spring, exit animation faltando |
| React | Error boundary faltando, prop drilling, key em listas |

**Regras inviolaveis:**
- NUNCA auto-corrige — sempre apresenta e espera decisao do usuario
- NUNCA bloqueia operacoes por causa de sugestoes
- Maximo 5 sugestoes automaticas, 10 no scan manual
- Ordenado por severidade: HIGH > MEDIUM > LOW
- O usuario pode aplicar via `*apex-fix` (individual) ou `*apex-quick` (batch)

---

## Commands

### Entry Point (recomendado)
- `@apex {descricao}` — Descreve o que quer em linguagem natural, Apex resolve tudo

### Pipeline Commands
- `*apex-go {description}` — Full 7-phase pipeline (autonomous, pauses at 6 checkpoints)
- `*apex-step {description}` — Full pipeline, guided (pauses after each phase)
- `*apex-quick {description}` — Quick 3-phase pipeline (specify → implement → ship)
- `*apex-fix {description}` — Single-agent fix (route → execute → typecheck → done)
- `*apex-resume` — Resume paused/crashed pipeline
- `*apex-status` — Show current pipeline status
- `*apex-abort` — Cancel running pipeline
- `*apex-pivot` — Change direction mid-pipeline

### Visual Analysis Commands
- `*apex-analyze` — Analise visual profunda de screenshot/print (8 dimensoes, score, opcoes)
- `*apex-compare` — Comparacao lado a lado de 2 prints (delta por dimensao)
- `*apex-consistency` — Auditoria de consistencia cross-page (3+ prints)

### Quality & Audit Commands
- `*apex-review` — Code review multi-agente (patterns, architecture, perf, a11y)
- `*apex-dark-mode` — Auditoria dark mode (tokens, contraste, hardcoded colors)
- `*apex-critique {print or component}` — Design critique com principios formais (Gestalt, hierarquia visual)
- `*apex-export-tokens {format}` — Exportar tokens (Figma JSON, Style Dictionary, CSS, Tailwind, Markdown)
- `*apex-integration-test {flow}` — Setup de integration tests para interacoes compostas
- `*apex-refactor {component}` — Workflow de refactoring seguro (5 fases com baseline tests)

### Discovery Commands
- `*discover-components` — Inventariar todos os componentes, arvore de dependencias, orphans, testes
- `*discover-design` — Mapear design system real: tokens, violacoes, paleta, consistencia
- `*discover-routes` — Mapear todas as rotas, orphan routes, SEO gaps, dead routes
- `*discover-dependencies` — Saude das dependencias: outdated, vulneraveis, pesadas, unused
- `*discover-motion` — Inventario de animacoes, violacoes CSS→spring, reduced-motion gaps
- `*discover-a11y` — Scan estatico de acessibilidade, WCAG violations, keyboard traps
- `*discover-performance` — Lazy loading gaps, image audit, re-render risks, CWV risks

### Style Commands
- `*apex-inspire` — Navegar catalogo de 31 presets de design (Apple, Google, Stripe, brutalist, etc.)
- `*apex-transform --style {id}` — Aplicar estilo completo no projeto com 1 comando
- `*apex-transform --style {id} --scope page {path}` — Aplicar em pagina especifica
- `*apex-transform --style {id} --primary "#cor"` — Override de tokens especificos

### Autonomous Commands
- `*apex-scan` — Scan project (stack, structure, design patterns, conventions)
- `*apex-suggest` — Manual suggestion scan (finds issues across all components)

### Diagnostic Commands
- `*apex-audit` — Diagnose squad readiness for current project
- `*apex-agents` — List active agents for current profile

### Direct Agent Activation (opcional, para usuarios avancados)
- `@apex` or `@apex-lead` — Orchestrator (Emil) — auto-roteia
- `@css-eng` — CSS specialist (Josh)
- `@react-eng` — React specialist (Kent)
- `@motion-eng` — Motion specialist (Matt)
- `@a11y-eng` — Accessibility specialist (Sara)
- `@perf-eng` — Performance specialist (Addy)
- `@qa-visual` — Visual QA (Andy)
- `@interaction-dsgn` — Interaction Designer (Ahmad)

**Nota:** Na maioria dos casos, `@apex {descricao}` e suficiente — nao precisa chamar agente diretamente.

---

## Veto Conditions (Inline Summary)

These conditions BLOCK progress. They are physical blocks, not suggestions.

| Gate | Condition | Block |
|------|-----------|-------|
| QG-AX-001 | Hardcoded hex/px values in components | Cannot pass design review |
| QG-AX-005 | axe-core violations found | Cannot ship |
| QG-AX-005 | Missing prefers-reduced-motion | Cannot ship |
| QG-AX-006 | CSS transition used for motion (not spring) | Cannot pass motion review |
| QG-AX-007 | LCP > 1.2s or bundle > budget | Cannot ship |
| QG-AX-010 | TypeScript or lint errors | Cannot ship |
| QG-AX-010 | apex-lead has not signed off | Cannot ship (non-waivable) |

**Adaptive enforcement:** Veto conditions that reference tooling not present in the project (e.g., Chromatic, Storybook, Playwright) are automatically SKIPPED with a warning, not BLOCKED. See `data/veto-conditions.yaml` for `available_check` per condition.

---

## Discovery Tools — "Eu ja sei o que voce tem"

Discovery tools escaneiam o codebase real do projeto. Eliminam exploracao manual — o squad ja sabe o inventario completo antes de agir. **7 discovery tools** cobrem todas as dimensoes do frontend.

### `*discover-components` — Component Discovery

Inventaria TODOS os componentes React do projeto:
- **Component map:** nome, tipo (page/layout/ui/hook), LOC, imports, importado por
- **Dependency tree:** quem importa quem, componentes hub (alto impacto)
- **Orphans:** componentes exportados mas nunca importados (dead code)
- **Quality:** sem testes, sem Error Boundary, god components (>200 LOC + >5 hooks)
- **Health score:** 0-100 baseado em cobertura, orphans, complexidade

### `*discover-design` — Design System Discovery

Mapeia o design system REAL (o que esta no codigo, nao o planejado):
- **Token inventory:** CSS variables, Tailwind config, theme objects
- **Usage:** cores, spacing, tipografia, radius, z-index realmente usados
- **Violations:** valores hardcoded que deveriam usar tokens (alimenta QG-AX-001)
- **Near-duplicates:** cores com <5% distancia HSL (consolidar?)
- **DS Score:** 0-100 (solid/emerging/adhoc)
- **Design language:** glass morphism, material, flat, neumorphism, custom

### `*discover-routes` — Route Discovery

Mapeia TODAS as rotas/paginas do projeto:
- **Route map:** path, component, layout, params, guards
- **Orphan routes:** definidas mas nenhum nav/link aponta para elas
- **Dead routes:** importam componentes que nao existem
- **SEO gaps:** paginas sem title, meta description, og:image
- **Missing layouts:** paginas sem layout wrapper
- **Route health score:** 0-100

### `*discover-dependencies` — Dependency Health

Audita todas as dependencias frontend:
- **Outdated:** pacotes com major version atras
- **Vulnerable:** npm audit integrado
- **Heavy:** pacotes que inflam bundle (com alternativas leves sugeridas)
- **Duplicated:** mesma lib em versoes diferentes
- **Unused:** instalado mas nunca importado (safe to remove)
- **Dependency health score:** 0-100

### `*discover-motion` — Motion Discovery

Inventaria TODAS as animacoes e transicoes:
- **Animation map:** componente, tipo, lib, trigger, propriedades
- **CSS transitions → springs:** violacoes do veto QG-AX-006
- **Missing reduced-motion:** violacoes do veto QG-AX-005
- **Missing exit animations:** entra mas nao sai
- **Non-GPU animations:** animando width/height em vez de transform/opacity
- **Motion health score:** 0-100

### `*discover-a11y` — Accessibility Discovery

Scan estatico de acessibilidade (sem browser):
- **Missing alt text:** imagens sem alternativa textual
- **Missing form labels:** inputs sem label associado
- **Color contrast:** estimativa de contraste texto/fundo
- **Keyboard traps:** modais/drawers sem focus trap ou Escape
- **ARIA misuse:** roles incorretos, aria-hidden em focaveis
- **Heading structure:** niveis pulados, multiplos h1
- **A11y health score:** 0-100

### `*discover-performance` — Performance Discovery

Analise estatica de performance (sem Lighthouse):
- **Lazy loading gaps:** paginas/componentes pesados carregados eager
- **Image audit:** sem lazy load, sem dimensions, formato antigo
- **Re-render risks:** objetos inline em props, context sem slice
- **Bundle risks:** import *, barrel files, JSON pesado
- **Third-party cost:** scripts externos e impacto estimado
- **CWV risks:** LCP, INP, CLS patterns detectados no codigo
- **Performance health score:** 0-100

### Quando rodam

| Trigger | Discovery |
|---------|-----------|
| "como ta o design system?" | `*discover-design` |
| "quais componentes existem?" | `*discover-components` |
| "quais rotas tem?" | `*discover-routes` |
| "dependencias desatualizadas?" | `*discover-dependencies` |
| "como tao as animacoes?" | `*discover-motion` |
| "ta acessivel?" | `*discover-a11y` |
| "ta rapido?" | `*discover-performance` |
| "audita o projeto" | TODOS rodam como parte de `*apex-audit` |

Todos os discoveries alimentam `*apex-suggest` e cache em `.aios/apex-context/`.

---

## Style Presets — "Transforma com 1 comando"

O squad inclui um catalogo de **31 design presets** que cobrem os principais estilos visuais do mercado. Cada preset define um design language COMPLETO: cores, tipografia, spacing, radius, shadows, motion e component patterns.

### Categorias

| Categoria | Presets | Exemplos |
|-----------|---------|----------|
| **Apple** | 3 | Liquid Glass, HIG Classic, visionOS Spatial |
| **Google** | 2 | Material 3, Material You |
| **Tech Companies** | 7 | Linear, Vercel, Stripe, Notion, GitHub, Spotify, Discord |
| **Design Movements** | 7 | Glassmorphism, Neumorphism, Brutalist, Minimalist, Y2K, Claymorphism, Aurora |
| **Industry** | 5 | Healthcare, Fintech, SaaS, E-commerce, Education |
| **Dark Themes** | 3 | Dark Elegant, OLED Black, Nord |
| **Experimental** | 4 | Neubrutalism, Cyberpunk, Organic, Swiss Grid |

### Como usar

```
@apex "quero estilo Apple liquid glass"       → *apex-transform --style apple-liquid-glass
@apex "mostra estilos disponiveis"            → *apex-inspire
@apex "transforma pra estilo Stripe"          → *apex-transform --style stripe-style
@apex "quero dark elegante com dourado"       → *apex-transform --style dark-elegant
@apex "aplica material design"                → *apex-transform --style material-3
```

### Fluxo de transformacao

1. `*apex-inspire` — Navegar e escolher (opcional)
2. `*apex-transform --style {id}` — Scan atual → diff report → plano → executa
3. Agentes envolvidos: @design-sys-eng (tokens) → @css-eng (CSS) → @motion-eng (motion) → @a11y-eng (contraste)
4. Typecheck + lint + suggestions apos aplicar

### Override de tokens

Usar preset como base mas customizar:
```
*apex-transform --style stripe --primary "#FF0000" --font "Poppins"
```

### Catalogo extensivel

Novos presets podem ser adicionados em `data/design-presets.yaml` sem modificar tasks ou agentes.

Ver `data/design-presets.yaml` para especificacoes completas de cada preset.

---

## AIOS Integration

### Handoff to @devops
When shipping (Phase 7), Apex generates a handoff artifact at `.aios/handoffs/` before delegating to `@devops`:
```yaml
handoff:
  from_agent: apex-lead
  to_agent: devops
  story_context: { story_id, branch, status, files_modified }
  next_action: "*push"
```

### Agent Authority
- Apex agents can: `git add`, `git commit`, `git status`, `git diff`, edit files, run tests
- Apex agents CANNOT: `git push`, `gh pr create`, manage CI/CD — delegate to `@devops`
- Apex agents follow the AIOS agent-handoff protocol for context compaction on agent switches

---

*Apex Squad CLAUDE.md — Auto-generated for project-level integration*
