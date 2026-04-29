# Checklist — Aprovação de Design da Biblioteca

> Usado em PHASE_3 do wf-prd-to-lib.yaml antes de avançar para geração de scripts.
> Responsável: @lib-architect — apresentar ao usuário para revisão explícita.

## Antes de Apresentar o Design

- [ ] Todas as oportunidades do mapa (PHASE_2) têm função correspondente no design
- [ ] Nenhuma função inventada além das oportunidades mapeadas
- [ ] Estrutura de pastas definida e reflete domínio de negócio
- [ ] Cada função tem nome em português autoexplicativo
- [ ] Cada função tem assinatura com type hints definida
- [ ] Dependências necessárias listadas e justificadas

## Revisão com o Usuário

O @lib-architect deve perguntar explicitamente:

- [ ] "Os nomes das funções fazem sentido para você sem precisar de explicação?"
- [ ] "A organização por pastas está clara?"
- [ ] "Alguma função que você esperava não está na lista?"
- [ ] "Alguma função na lista que você não precisa?"

## Aprovação

- [ ] Usuário confirmou explicitamente que o design está correto
- [ ] Nenhum ajuste pendente de nome ou escopo
- [ ] Se houve ajustes: design foi atualizado e re-apresentado
- [ ] Usuário deu sinal claro de aprovação (ex: "sim", "pode gerar", "aprovado")

## Gate — Antes de Avançar para PHASE_4

**VETO se qualquer item abaixo for verdadeiro:**

- [ ] Usuário não respondeu ou saiu sem confirmar → **BLOQUEAR**
- [ ] Usuário pediu alteração mas ainda não confirmou o novo design → **BLOQUEAR**
- [ ] Existe função no design sem oportunidade correspondente no mapa → **BLOQUEAR**

---

*Checkpoint CP_003 do wf-prd-to-lib.yaml — aprovação obrigatória antes da geração*
