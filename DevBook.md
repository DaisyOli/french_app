# DevBook: Aplicativo de Prática de Francês

## Visão Geral
Este aplicativo é projetado para professores de francês criarem atividades personalizadas para seus alunos praticarem o idioma. Os professores podem criar diferentes tipos de atividades com questões, materiais visuais, textos e sugestões.

## Modelos de Dados

### 1. Activity (Atividade)
- **Descrição**: Representa uma atividade completa de prática
- **Atributos**:
  - `título` - Nome da atividade
  - `nível` - Nível de dificuldade (A1, A2, B1, etc.)
  - `texto` - Texto opcional para leitura
  - `video_url` - Link opcional para vídeo
  - `imagem_url` - Link opcional para imagem
  - `timestamps` - Data de criação e atualização

### 2. Statement (Enunciado)
- **Descrição**: Enunciados que podem aparecer em diferentes pontos da atividade
- **Atributos**:
  - `conteúdo` - O texto do enunciado
  - `activity_id` - Relação com a atividade
  - `timestamps` - Data de criação e atualização

### 3. Question (Questão)
- **Descrição**: Questões que fazem parte da atividade
- **Atributos**:
  - `conteúdo` - O texto da pergunta
  - `tipo` - Tipo de questão (múltipla escolha, inicialmente)
  - `activity_id` - Relação com a atividade
  - `timestamps` - Data de criação e atualização

### 4. Alternative (Alternativa)
- **Descrição**: Alternativas para questões de múltipla escolha
- **Atributos**:
  - `conteúdo` - Texto da alternativa
  - `correta` - Indica se é a resposta correta
  - `question_id` - Relação com a questão
  - `timestamps` - Data de criação e atualização

### 5. Suggestion (Sugestão)
- **Descrição**: Sugestões do professor que podem aparecer ao longo da atividade
- **Atributos**:
  - `conteúdo` - Texto da sugestão
  - `activity_id` - Relação com a atividade
  - `timestamps` - Data de criação e atualização

## Relacionamentos

- Uma **Activity** tem muitos **Statements** (1:N)
- Uma **Activity** tem muitas **Questions** (1:N)
- Uma **Activity** tem muitas **Suggestions** (1:N)
- Uma **Question** tem muitas **Alternatives** (1:N)

## Funcionalidades Principais

### Para Professores
- [ ] Autenticação de professores
- [ ] CRUD de atividades
- [ ] Adição de enunciados em diferentes posições
- [ ] Upload ou link para recursos (vídeos, imagens)
- [ ] Criação de questões de múltipla escolha
- [ ] Adição de sugestões em diferentes posições
- [ ] Visualização de desempenho dos alunos

### Para Alunos
- [ ] Autenticação de alunos
- [ ] Listagem de atividades disponíveis
- [ ] Realização de atividades
- [ ] Visualização de resultados e feedback
- [ ] Acompanhamento de progresso

## Fluxo de Desenvolvimento

### Fase 1: Configuração e Modelos Básicos
- [ ] Configurar o projeto Rails
- [ ] Implementar autenticação (Devise)
- [ ] Criar modelos e migrações
- [ ] Definir relacionamentos entre modelos
- [ ] Criar seeds para testes

### Fase 2: Interface do Professor
- [ ] Implementar CRUD de atividades
- [ ] Desenvolver interface para criação de questões
- [ ] Implementar fluxo sequencial de criação de elementos
- [ ] Implementar preview de atividades

### Fase 3: Interface do Aluno
- [ ] Desenvolver listagem de atividades
- [ ] Criar interface para realização de atividades
- [ ] Implementar sistema de avaliação automática
- [ ] Desenvolver dashboard de progresso

### Fase 4: Refinamentos
- [ ] Adicionar suporte a mais tipos de questões
- [ ] Melhorar UX/UI
- [ ] Implementar recursos de gamificação
- [ ] Adicionar análises e relatórios

## Tecnologias Sugeridas

- **Backend**: Ruby on Rails
- **Frontend**: 
  - Opção 1: Hotwire (Turbo + Stimulus) para uma abordagem tradicional do Rails
  - Opção 2: React/Vue com API Rails para uma experiência mais interativa
- **Banco de Dados**: PostgreSQL
- **Autenticação**: Devise
- **Upload de Imagens**: Active Storage com serviço de armazenamento
- **CSS**: TailwindCSS ou Bootstrap

## Considerações Futuras

- Implementação de sistema drag and drop para reorganização dos elementos da atividade
- Implementação de mais tipos de questões (arrastar e soltar, preencher lacunas, etc.)
- Sistema de notificações para alunos
- Integração com APIs de tradução ou dicionários
- Sistema de gamificação mais avançado
- Recursos de áudio para pronúncia 