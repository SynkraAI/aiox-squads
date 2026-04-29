---
task:
  name: generateScripts()
  responsavel: "@script-writer"
  responsavel_type: Agente
  atomic_layer: Template

Entrada:
  - lib_design (object → Memory, obrigatório)
  - design_approved (boolean → Memory, obrigatório — BLOQUEADO se false)

inputs:
  - campo: lib_design
    tipo: object
    origem: Memory (from designLibStructure — MUST be approved)
    obrigatorio: true
  - campo: design_approved
    tipo: boolean
    origem: Memory
    obrigatorio: true
    validacao: "MUST be true — task is blocked if false"

Saida:
  - generated_scripts (array de .py → victor-libs/{dominio}/{modulo}.py)

Checklist:
  - "[ ] Verificar design_approved === true antes de iniciar"
  - "[ ] Gerar cada arquivo .py do design"
  - "[ ] Implementar todas as funções com docstrings em português"
  - "[ ] Garantir ausência de funções além do design aprovado"

outputs:
  - campo: generated_scripts
    tipo: array
    destino: File
    persistido: true
    path: "victor-libs/{dominio}/{modulo}.py"

preConditions:
  - condition: "lib_design aprovado pelo usuário (design_approved === true)"
    errorMessage: "Design não aprovado. Aguarde aprovação antes de gerar scripts."

steps:
  - id: "1"
    description: "Gerar cada arquivo .py do design"
    actions:
      - "Para cada arquivo no design: criar arquivo .py no caminho correto"
      - "Adicionar docstring de módulo no topo (o que o módulo faz, domínio)"
      - "Importar apenas dependências listadas no design"

  - id: "2"
    description: "Implementar cada função"
    actions:
      - "Seguir exatamente a assinatura do design (nome, params, tipos)"
      - "Adicionar docstring completa em português: descrição, parâmetros, retorno, exceções"
      - "Implementar lógica com tratamento de erro"
      - "Garantir retorno consistente com tipo definido"

  - id: "3"
    description: "Verificar conformidade com design"
    actions:
      - "Confirmar que cada função do design foi implementada"
      - "Confirmar que nenhuma função extra foi adicionada"
      - "Se desvio detectado: reportar ao Forge antes de continuar"

autoClaude:
  deterministic: true
  elicit: false
  composable: true
  pipelinePhase: generation
  verification:
    type: manual
    description: "Passado para @lib-validator após geração"
---

# generateScripts()

Gera os arquivos Python seguindo estritamente o design aprovado.

## Padrão de Código

```python
"""
Módulo: {modulo}.py
Domínio: {dominio}
Descrição: {descricao_do_modulo}
"""

from typing import Optional
import requests  # apenas dependências do design


def nome_da_funcao(
    param1: str,
    param2: int
) -> list[dict]:
    """
    Descrição clara do que a função faz.

    Parâmetros:
        param1: O que é este parâmetro e exemplo
        param2: O que é este parâmetro e exemplo

    Retorna:
        Descrição do que é retornado e estrutura

    Lança:
        Exception: Quando e por quê pode falhar
    """
    try:
        # implementação
        resultado = ...
        return resultado
    except Exception as e:
        raise Exception(f"Mensagem clara em português: {e}")
```
