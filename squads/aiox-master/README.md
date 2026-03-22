# 🎯 AIOX Master

> Meta-orquestrador do ecossistema de squads AIOX FelippePestana.

**Versão:** 1.0.0 | **Status:** 🟢 OPERATIONAL

---

## O que é

O **AIOX Master** é o orquestrador de mais alto nível do repositório. Não executa trabalho especializado — ele **coordena**, **valida** e **roteia** entre os squads existentes.

```
@aiox-master
*validate analista-processual
```

---

## Squads do Ecossistema

| Squad | Domínio | Status |
|-------|---------|--------|
| `analista-processual` | Análise de processos judiciais (CPC/2015) | 🟢 OPERATIONAL |
| `apex` | Frontend ultra-premium (web/mobile/spatial) | 🟢 OPERATIONAL |
| `curator` | Curadoria e gestão de conteúdo | 🟡 ACTIVE |
| `deep-research` | Pesquisa profunda e síntese | 🟡 ACTIVE |
| `dispatch` | Execução paralela — pipeline DAG | 🟡 ACTIVE |
| `education` | Engenharia instrucional | 🟢 PRODUCTION |
| `kaizen` | Monitoramento do ecossistema | 🟡 ACTIVE |
| `seo` | SEO e visibilidade orgânica | 🟢 OPERATIONAL |
| `squad-creator` | Criação e validação de squads | 🟡 ACTIVE |

---

## Comandos

| Comando | Função |
|---------|--------|
| `*validate {squad}` | Validar integridade de um squad |
| `*validate-all` | Validar todos os squads |
| `*ecosystem-status` | Status rápido do ecossistema |
| `*analyze-all` | Análise completa via kaizen |
| `*route {pedido}` | Rotear pedido para o squad correto |
| `*list-squads` | Listar todos os squads com metadados |
| `*gaps` | Identificar gaps de cobertura |
