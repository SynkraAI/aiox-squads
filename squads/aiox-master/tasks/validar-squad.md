# validar-squad

## Task: Validação Completa de Squad

### Metadata
- **executor:** aiox-master (orquestra squad-creator:validate-squad + verificação própria)
- **elicit:** true
- **output:** relatorio-validacao-{squad}.md

### Objetivo
Verificar a integridade estrutural, qualidade dos agentes, consistência de referências
e score AIOX de um squad, gerando relatório com resultado e recomendações.

### Inputs
```
squad_name: Nome da pasta do squad (ex: analista-processual)
```

### Fases de Execução

#### FASE 1 — Inventário de Arquivos
Verificar existência de:
- [ ] `squads/{squad}/config.yaml`
- [ ] `squads/{squad}/README.md`
- [ ] `squads/{squad}/agents/` (min. 1 arquivo .md)
- [ ] `squads/{squad}/tasks/` (min. 1 arquivo .md) — recomendado
- [ ] `squads/{squad}/CHANGELOG.md` — recomendado

#### FASE 2 — Validação do config.yaml
Campos obrigatórios:
- [ ] `name` — ID do squad
- [ ] `version` — semver
- [ ] `description` — descrição clara do domínio
- [ ] `tier_structure` — hierarquia de agentes definida
- [ ] Pelo menos 1 agente em `tier_0` ou `tier_structure.tier_0`

#### FASE 3 — Validação de Agentes
Para cada arquivo em `agents/`:
- [ ] Tem `activation-instructions` com ao menos 3 STEPs
- [ ] Tem `agent.name` e `agent.id`
- [ ] Tem `persona.role`
- [ ] Tem `commands` (lista de pelo menos 2)
- [ ] Tem `heuristics` (lista com id + rule)
- [ ] `agent.id` bate com o nome do arquivo (sem .md)

#### FASE 4 — Validação de Tasks
Para cada task referenciada em `dependencies.tasks`:
- [ ] Arquivo existe em `squads/{squad}/tasks/`
- [ ] Task tem `executor` definido
- [ ] Task tem passos de execução

#### FASE 5 — Consistência de Paths
- [ ] Paths em `IDE-FILE-RESOLUTION` correspondem ao caminho real do squad
- [ ] Arquivos de `data/` referenciados existem
- [ ] Agents referenciados em `agents_acionados` existem

#### FASE 6 — Score AIOX

| Dimensão | Peso | Critério |
|----------|------|---------|
| Estrutura de Arquivos | 30pts | config + README + agents/ presentes e válidos |
| Qualidade dos Agentes | 30pts | activation + persona + commands + heuristics em cada agente |
| Cobertura de Tasks | 20pts | tasks referenciadas existem + têm passos executáveis |
| Heurísticas | 10pts | min. 4 heurísticas com id + rule no chief |
| Documentação | 10pts | README claro + CHANGELOG presente |

**Total: 100pts**
- `< 70` → DRAFT 🔴
- `70-89` → DEVELOPING 🟡
- `≥ 90` → OPERATIONAL 🟢

### Formato de Saída

```markdown
# Relatório de Validação — Squad: {squad_name}

**Data:** {data}
**Validado por:** AIOX Master v1.0.0
**Score:** {N}/100
**Status:** DRAFT 🔴 | DEVELOPING 🟡 | OPERATIONAL 🟢

---

## Resultado por Fase

| Fase | Resultado | Score |
|------|-----------|-------|
| 1. Estrutura de Arquivos | ✅ PASS / ❌ FAIL | {N}/30 |
| 2. config.yaml | ✅ PASS / ❌ FAIL | — |
| 3. Agentes | ✅ PASS / ⚠️ WARN / ❌ FAIL | {N}/30 |
| 4. Tasks | ✅ PASS / ⚠️ WARN | {N}/20 |
| 5. Consistência de Paths | ✅ PASS / ⚠️ WARN | — |
| 6. Score Final | — | {N}/100 |

---

## Detalhamento por Agente

### {nome_agente}
- activation-instructions: ✅ / ❌
- agent.id/name: ✅ / ❌
- persona: ✅ / ❌
- commands: ✅ ({N} comandos) / ❌
- heuristics: ✅ ({N} heurísticas) / ❌

---

## Issues Encontrados

### 🔴 BLOQUEANTES (impedem OPERATIONAL)
{lista ou "Nenhum"}

### 🟡 RECOMENDAÇÕES (melhoram o score)
{lista ou "Nenhuma"}

### 🟢 PONTOS FORTES
{lista}

---

## Recomendações para Próxima Versão
1. {recomendação priorizada}
2. ...
```
