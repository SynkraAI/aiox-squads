---
task: Criar Paleta de Cores
agent: ui-ux-expert
responsavel: "@ui-ux-expert"
responsavel_type: agent
atomic_layer: task
icon: "🎨"
elicit: true
Entrada: |
  - briefing_completo: Briefing com tom e referências da marca
  - referencias_visuais: Sites ou imagens de referência
  - publico_alvo: Persona definida
Saida: |
  - paleta_cores: Paleta completa com hexadecimais
  - uso_de_cada_cor: Guia de uso por contexto
  - acessibilidade: Verificação de contraste WCAG AA
Checklist:
  - "[ ] Definir cor primária (identidade)"
  - "[ ] Definir cor de destaque/CTA"
  - "[ ] Definir neutras (fundo, texto)"
  - "[ ] Verificar contraste WCAG AA (4.5:1)"
  - "[ ] Testar em fundo claro e escuro"
  - "[ ] Documentar uso correto"
---

# *color-palette

Cria paleta de cores estratégica baseada em psicologia das cores, identidade de marca e acessibilidade.

## Psicologia das cores por segmento

| Cor | Emoção | Ideal para |
|-----|--------|-----------|
| Azul | Confiança, segurança | Finanças, saúde, tech |
| Verde | Crescimento, natureza | Saúde, sustentabilidade |
| Laranja | Energia, urgência | CTAs, e-commerce |
| Roxo | Premium, criatividade | Luxo, design, educação |
| Vermelho | Urgência, paixão | Promoções, food |
| Preto | Sofisticação | Luxo, moda |

## Contraste WCAG AA

- Texto normal: mínimo 4.5:1
- Texto grande (18px+): mínimo 3:1
- Componentes UI: mínimo 3:1

## Output

```markdown
# Paleta de Cores — [Projeto]

| Papel | Nome | Hex | Contraste s/ branco |
|-------|------|-----|---------------------|
| Primária | [nome] | #XXXXXX | X.X:1 |
| CTA/Destaque | [nome] | #XXXXXX | X.X:1 |
| Texto principal | [nome] | #XXXXXX | X.X:1 |
| Fundo | [nome] | #XXXXXX | — |
| Fundo alternativo | [nome] | #XXXXXX | — |
| Alerta/Erro | [nome] | #XXXXXX | X.X:1 |
```
