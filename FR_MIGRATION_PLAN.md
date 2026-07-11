# Practice FR — Plano de Migração (briefing de missão)

> Escrito em 2026-07-10 pela sessão do exercise_app (Practice BR), que já analisou
> este repositório. **Sessão nova: leia este arquivo inteiro antes de qualquer
> mudança**, e leia também o contrato da franquia no repo irmão:
> `~/code/exercise_app/docs/DESIGN_SYSTEM.md` e `docs/design_system.html`
> (abra a sessão com `claude --add-dir ~/code/exercise_app`).

## Contexto: a franquia Practice

Daisy tem dois apps irmãos: **Practice BR** (`~/code/exercise_app`, português,
app.practicebr.com) e **Practice FR** (este repo, francês, practicefr.com, Heroku).
Objetivo: mesma **estrutura** de design (a franquia), **paletas** diferentes (a marca).
O BR já fez a Sprint 1 da franquia: todos os hex viraram tokens CSS
(`var(--brand)`, `var(--ink)`, `var(--paper)`... nomes em INGLÊS, iguais nos dois
apps — só os VALORES mudam). Fonte de verdade lá: `app/assets/stylesheets/_tokens.scss`.

## Estado deste repo (diagnóstico de 2026-07-10)

- Rails 7.1 + Ruby 3.3.5 (mesma base do BR) — Devise, Stimulus, importmap. Branch `master`.
- **Bootstrap 5.3 DUPLICADO**: via gem (`bootstrap` + `sassc-rails` no Gemfile) E via CDN no layout. Sem Tailwind/DaisyUI.
- `app/assets/stylesheets/application.css`: 411 linhas; identidade atual é o gradiente
  roxo genérico `#667eea → #764ba2` + rosas (#FF69B4) — sem marca própria (bom: nada a preservar).
- 53 views ERB; ~19 usam grid/componentes Bootstrap; 8 têm estilos inline.
- **Higiene pendente**: `node_modules/` COMMITADO (13MB), `application.css.backup`,
  pasta órfã `french_app/tmp` dentro do repo.
- Curiosidade útil: aqui múltipla escolha e lacuna JÁ são models próprios
  (`alternative.rb`, `fill_blank.rb`, `blank.rb`) — arquitetura que o BR ainda quer (R9).

## Sprints (nesta ordem)

### Sprint 0 — Higiene do repositório (1 sentada, sem mudança visual)
1. Tirar `node_modules/` do git (`git rm -r --cached node_modules` + `.gitignore`).
2. Apagar `app/assets/stylesheets/application.css.backup` e a pasta órfã `french_app/`.
3. Resolver o Bootstrap duplicado: manter SÓ a gem por enquanto (remover o `<link>` CDN
   do layout) — a remoção total do Bootstrap vem na migração página a página.
4. Conferir o deploy: remote heroku, Procfile, como rodam as migrações; fazer um
   deploy de validação depois da faxina.

### Sprint 1-FR — Fundação da franquia
1. Instalar `tailwindcss-rails` + DaisyUI (mesmas versões do BR: DaisyUI v4, tailwindcss-rails ~3.3).
2. Copiar do BR: `app/assets/stylesheets/_tokens.scss` (manter os NOMES; valores
   provisórios = os do BR até a Sprint 2-FR), `docs/DESIGN_SYSTEM.md`,
   `docs/design_system.html`, `scripts/tokenize_colors.rb`.
3. `tailwind.config.js` no padrão do BR: `extend.colors` lendo os tokens
   (`brand`, `action`, `ink`, `paper`, `line`...), tema DaisyUI **`practice-fr`**,
   fontes (`Raleway`/`Plus Jakarta Sans`/`DM Mono` — franquia) e raios 8/12/18/24px.

### Sprint 2-FR — Nascer a marca francesa (decisão de design da Daisy)
> **STATUS 2026-07-11: decidida — Bordeaux crème** (bordô #8A2545/#5C1630 sobre
> creme #FAF6EF, action dourado #C08A28, brand-soft rosa empoeirado #C08A95).
> Branding completo em `branding/fr/` (logo vetorial, Raleway SemiBold 600, sem
> subtítulo). Falta só gravar os valores em `_tokens.scss`/tema DaisyUI (início do Sprint 3).
1. Criar `mockup.html` com 3–4 direções de paleta preenchendo os MESMOS tokens
   (ex.: evoluir o roxo atual para uma família roxa "de gente grande"; azul-França +
   accent quente; bordô/creme). Mostrar cada direção trocando só o bloco `:root`.
2. Daisy escolhe. Gravar a paleta vencedora em `_tokens.scss` + tema DaisyUI +
   bloco `:root` do `docs/design_system.html` local.
3. Apagar o `mockup.html` ao final (regra dela: um mockup ativo por vez; o
   `design_system.html` é a referência permanente).

### Sprint 3+ — Migração página a página (receita R8 do BR)
Ordem sugerida: layout/navbar → telas Devise → lista de atividades → show/quiz → admin.

> **Cards, grid e responsividade NÃO se recriam — se PORTAM do BR.** O trabalho
> que a Daisy fez nos cards/responsividade do Practice-BR é estrutura da franquia
> (classes Tailwind/DaisyUI); copiar/adaptar o markup das views equivalentes do BR
> e deixar os tokens pintarem de bordô. Abrir a sessão com
> `claude --add-dir ~/code/exercise_app` pra ler as views de lá.
> **Critério de qualidade:** a franquia Practice é peça de portfólio — tem que
> ficar incrível para recrutadores (polimento visual, estados vazios com charme,
> responsividade impecável).
Por página: substituir classes Bootstrap por Tailwind/DaisyUI com tokens; collapses
viram Stimulus; `form-control` → `form-input`; hex que sobrar → rodar
`scripts/tokenize_colors.rb` (ajustar o mapa hex→token para a paleta local; dry-run
antes de `--apply`; mailers e `theme-color` ficam com hex). Ao final de tudo: remover
a gem `bootstrap` + `sassc-rails`.

## Regras de trabalho da Daisy (valem aqui também)

- **Fofura é requisito de produto**: loading/empty states com personalidade; refatoração
  não pode "esfriar" a experiência.
- **Hierarquia de botões da franquia**: CTA de rodapé = `--brand`; compacto = `--brand-deep`;
  submit de formulário = `--action`. Consultar o DESIGN_SYSTEM.md antes de criar botão.
- **Nunca hex em view** — sempre `var(--token)`. Exceções: mailers, `<meta theme-color>`, tema DaisyUI.
- **Verificação**: nunca resetar senha de usuário real; criar usuário temporário.
- Ela é professora que aprendeu a programar: linguagem simples, um conceito novo por vez,
  analogias, tom encorajador. Commits pequenos com mensagens em português contando a história.
- Testar local antes de subir; deploy só com o ok dela.
