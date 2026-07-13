# Practice FR — Plano de Migração (briefing de missão)

> Escrito em 2026-07-10 pela sessão do exercise_app (Practice BR), que já analisou
> este repositório. Atualizado em 2026-07-13 com o estado real depois da migração
> página a página (Sprint 3) e o novo roteiro de features (Sprint 4-FR em diante).
> **Sessão nova: leia este arquivo inteiro antes de qualquer mudança**, e leia
> também o contrato da franquia no repo irmão:
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

### Sprint 0 — Higiene do repositório ✅ CONCLUÍDA
### Sprint 1-FR — Fundação da franquia ✅ CONCLUÍDA
### Sprint 2-FR — Nascer a marca francesa ✅ CONCLUÍDA
> Paleta **Bordeaux crème** (bordô `#8A2545`/`#5C1630` sobre creme `#FAF6EF`, action
> dourado `#C08A28`, brand-soft rosa empoeirado `#C08A95`). Branding completo em
> `branding/fr/` (logo vetorial, Raleway SemiBold 600, sem subtítulo). Tokens
> gravados em `app/assets/stylesheets/_tokens.scss`.

### Sprint 3-FR — Migração página a página — ✅ CONCLUÍDA (2026-07-12/13)

> **Achado importante durante a Sprint 3**: o Practice-BR, na tela de exercícios
> (equivalente ao `show.html.erb` do FR), não tem um componente estrutural
> reutilizável pra "card de exercício" — é convenção copiada manualmente entre
> ~10 partials, não um padrão formal. Então a regra "cards/grid se portam do BR,
> não se recriam" valeu bem para telas de listagem (`.activity-card`,
> `.activities-grid`, dashboards), mas **não fazia sentido forçar pro
> `show.html.erb`** — lá o trabalho foi retoken visual (trocar cor por token),
> sem mexer na estrutura, porque a página tem lógica de negócio real embaralhada
> com a view e nenhum alvo estrutural limpo do BR pra copiar.

Páginas migradas (Bootstrap → tokens da franquia, `var(--token)`, sem hex cru):
- Navbar (`shared/_navbar.html.erb`) e Devise (login professor/aluno, sem os
  alertas automáticos do Devise — "conectado com sucesso" etc. removidos).
- Dashboard do aluno (`students/dashboard.html.erb`) e do professor
  (`users/index.html.erb`, antes um redirect vazio — nasceu do zero, direção
  visual "Adega": hero sólido em `--brand-deep`).
- Quiz/resolver atividade (`activities/solve.html.erb`) — todos os tipos de
  exercício na estrutura real do BR (não só cor).
- Formulário de criar/editar atividade (`activities/_form.html.erb`).
- Tela de exercícios (`activities/show.html.erb`) — **retoken visual apenas**
  (ver achado acima); redesenho estrutural fica pra uma sprint futura dedicada.
- Lista de atividades do professor (`activities/index.html.erb`) — ganhou busca,
  filtro por nível e ordenação (server-side, sem JS, como o BR).
- Convite de aluno (`students/invitations/new.html.erb`).
- Removido: gem `bootstrap` continua no Gemfile (não removida ainda — não bloqueou
  nada, fica pra depois se quiser).

**Achados de segurança corrigidos durante a Sprint 3** (não estavam no escopo
original, mas eram graves demais pra esperar):
- Atividade era resolvível sem login por link direto — corrigido, agora exige
  login (aluno ou professor) e volta pra atividade certa depois de logar.
- Professor conseguia editar/apagar atividade — e qualquer exercício dentro dela
  — de OUTRO professor, só sabendo o link (11 controllers de exercício sem
  checagem de dono; 5 deles nem exigiam login nenhum). Corrigido com um Concern
  (`app/controllers/concerns/activity_ownable.rb`) incluído nos 11.

### Sprint 4-FR a 8-FR — ver seção "Roteiro de features" abaixo — ✅ CONCLUÍDAS (2026-07-13)
A migração visual está encerrada. As sprints 4-8 foram features novas (convite
de professor, nível do aluno, perfil, percurso profissional), não mais retoken —
todas implementadas, testadas e deployadas (release v56→v58).

## Regras de trabalho da Daisy (valem aqui também)

- **Fofura é requisito de produto**: loading/empty states com personalidade; refatoração
  não pode "esfriar" a experiência.
- **Hierarquia de botões da franquia**: CTA de rodapé = `--brand`; compacto = `--brand-deep`;
  submit de formulário = `--action`. Consultar o DESIGN_SYSTEM.md antes de criar botão.
- **Nunca hex em view** — sempre `var(--token)`. Exceções: mailers, `<meta theme-color>`, tema DaisyUI.
- **Verificação**: nunca resetar senha de usuário real; criar usuário temporário.
- Ela é professora que aprendeu a programar: linguagem simples, um conceito novo por vez,
  analogias, tom encorajador. Commits pequenos com mensagens em português contando a história.
- Testar local antes de subir; deploy só com o ok dela — sprint por sprint, não em lote.
- **Ao mexer numa área do código, checar se a checagem de dono/autenticação existe** —
  a Sprint 3 revelou que vários controllers antigos não tinham (ver achados de
  segurança acima). Não presumir que "já deve estar protegido".

## Roteiro de features (Sprint 4-FR em diante) — planejado em 2026-07-13

Depois da migração visual (Sprint 3), a Daisy pediu 3 features novas do
practice-br: convite de professor, nível do aluno definido pelo professor (com
página de perfil dedicada, visão do professor), e "percurso profissional"
(OPCO/eCPF — programas reais de financiamento de formação francesa, não um
flag genérico — desbloqueia emissão de atestado de formação no BR).

Investigação no BR mostrou que nada disso porta 1:1: o BR não tem `Student`
separado (é tudo `User` com `role`), e convite de professor lá é restrito a um
papel `admin` que o FR ainda não tem. Decisões tomadas com a Daisy antes de
desenhar o roteiro: criar `admin` de verdade (não pular essa etapa), perfil do
aluno só do ponto de vista do professor (sem tela "meu perfil" pro aluno), e
o pacote completo do percurso profissional incluindo o atestado.

- **Sprint 4-FR** ✅ — Papel `admin` em `users` (`add_admin_to_users`), Daisy
  promovida via `heroku run rails runner` (única admin; sem UI de auto-promoção,
  igual ao BR). Fundação sem UI própria — nada lia o flag ainda.
- **Sprint 5-FR** ✅ — Convite de professor: `Users::InvitationsController`
  (mesmo padrão de `Students::InvitationsController`), gated por
  `current_user.admin?`; navbar ganha dropdown "Inviter" (aluno/professor) só
  pra admin; professor comum continua só com "Inviter un étudiant".
- **Sprint 6-FR** ✅ — Nível do aluno: coluna `nível` em `students` (CEFR A1-C2),
  definido no convite (pills CSS-only). **Restringe acesso** às atividades
  (`accessible_levels`, cumulativo — como o BR), decisão explícita da Daisy.
  Diferença deliberada do BR: nível em branco = acesso TOTAL (não zero), pra
  não travar aluno já existente antes desta coluna existir.
- **Sprint 7-FR** ✅ — Lista de alunos (`teacher_students#index`, busca + stats
  por aluno) + perfil individual (`#show`: nível editável, métricas, remover
  vínculo) — tudo escopado por `current_user.students`. Testado inclusive o
  caso de um professor tentar ver/editar aluno de outro (bloqueado).
- **Sprint 8-FR** ✅ — Coluna `professional_type` (OPCO/eCPF) em `students`,
  badge no perfil/lista/dashboard do aluno, atestado de formação imprimível
  (`teacher_students#attestation`, layout usa `content_for :hide_navbar`).
  Rastreamento de horas: FR não tinha timestamp de início de atividade (ao
  contrário do BR) — Daisy escolheu explicitamente **rastrear tempo real dali
  pra frente** (não estimar, não inventar duração retroativa). Nova coluna
  `completed_activities.started_at`, capturada via JS na abertura da atividade
  em `solve.html.erb`; duração capada em 2h/sessão (mesmo critério do BR).
  Atestado só soma atividades autoradas pelo próprio professor que assina.

Plano detalhado de cada sprint fica em `/home/daisyoli/.claude/plans/` durante
a implementação (um plano por sessão) — este documento só mantém o roteiro
geral e o que já foi feito.
