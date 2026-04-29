# Checklist — Qualidade de Script

## Por Função (verificar cada uma)
- [ ] Nome da função é autoexplicativo sem precisar de comentário
- [ ] Nome em snake_case
- [ ] Nome em português se domínio é em português
- [ ] Todos os parâmetros têm type hints (`: tipo`)
- [ ] Retorno tem type hint (`-> tipo`)
- [ ] Docstring presente logo após `def`
- [ ] Docstring em português
- [ ] Docstring documenta: o que faz, cada parâmetro, o retorno, possíveis exceções
- [ ] Tratamento de erro presente se faz chamada externa (API, banco, arquivo)
- [ ] Mensagem de exceção em português e explicativa
- [ ] Retorno consistente em todos os paths (não retorna None em um e dict em outro)
- [ ] Função não tem `print()` interno
- [ ] Função faz apenas uma coisa (um verbo de ação)
- [ ] Função tem máximo ~30 linhas de código real

## Por Arquivo
- [ ] Docstring de módulo no topo do arquivo
- [ ] Apenas imports de dependências listadas no design
- [ ] Estrutura segue o design aprovado
- [ ] Nenhuma função extra não prevista no design

## Compliance com Design
- [ ] Todas as funções do design foram implementadas
- [ ] Nenhuma função extra sem aprovação do usuário
- [ ] Nomes exatamente como no design aprovado
- [ ] Assinaturas (parâmetros + retorno) conforme design

## Resultado Final
- [ ] APROVADO: script pode ir para victor-libs/
- [ ] BLOQUEADO: lista de itens a corrigir com explicação e solução
