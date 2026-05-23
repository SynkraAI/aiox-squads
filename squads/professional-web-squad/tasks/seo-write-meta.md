---
task: Escrever Meta Tags
agent: seo-specialist
responsavel: "@seo-specialist"
responsavel_type: agent
atomic_layer: task
icon: "📈"
elicit: false
Entrada: |
  - copy_aprovado: Copy principal da página
  - keywords_primarias: Keywords mapeadas
Saida: |
  - title_tag: Title tag otimizado (50-60 chars)
  - meta_description: Meta description (150-160 chars)
  - og_tags: Open Graph tags para redes sociais
Checklist:
  - "[ ] Title tag com keyword primária"
  - "[ ] Meta description com CTA"
  - "[ ] OG:title, OG:description, OG:image"
  - "[ ] Twitter Card tags"
  - "[ ] Canonical URL"
---

# *write-meta

Cria todas as meta tags necessárias para SEO e compartilhamento em redes sociais.

## Regras de ouro

**Title tag:**
- 50-60 caracteres
- Keyword no início
- Inclui nome da marca no final
- Formato: `[Keyword Principal] — [Benefício] | [Marca]`

**Meta description:**
- 150-160 caracteres
- Inclui keyword naturalmente
- Tem um CTA implícito
- Descreve o benefício real da página

## Output

```html
<!-- SEO Tags -->
<title>[keyword] — [benefício] | [Marca]</title>
<meta name="description" content="[150-160 chars com keyword e CTA]">
<link rel="canonical" href="[URL]">

<!-- Open Graph -->
<meta property="og:title" content="[título para redes sociais]">
<meta property="og:description" content="[descrição para redes sociais]">
<meta property="og:image" content="[URL da imagem 1200x630]">

<!-- Twitter Card -->
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="[título]">
<meta name="twitter:description" content="[descrição]">
```
