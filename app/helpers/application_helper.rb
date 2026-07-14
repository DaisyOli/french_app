module ApplicationHelper
  # Cores dos badges CEFR — contrato da franquia Practice (mesmos tokens do BR),
  # com rótulos em francês e o C2 que só o FR usa.
  CEFR_COLORS = {
    'A1' => { bg: 'var(--brand-tint)',   text: 'var(--brand-deep)',  border: 'var(--brand-bright)', bar: 'var(--brand-bright)', label: 'Débutant' },
    'A2' => { bg: 'var(--info-tint)',    text: 'var(--info-deep)',   border: 'var(--info)',         bar: 'var(--info)',         label: 'Élémentaire' },
    'B1' => { bg: 'var(--violet-tint)',  text: 'var(--violet-deep)', border: 'var(--violet)',       bar: 'var(--violet)',       label: 'Intermédiaire' },
    'B2' => { bg: 'var(--warning-tint)', text: 'var(--warning-ink)', border: 'var(--warning)',      bar: 'var(--warning)',      label: 'Intermédiaire avancé' },
    'C1' => { bg: 'var(--neutral-tint)', text: 'var(--ink)',         border: 'var(--neutral-ink)',  bar: 'var(--neutral-ink)',  label: 'Avancé' },
    'C2' => { bg: 'var(--paper-2)',      text: 'var(--ink)',         border: 'var(--ink-soft)',     bar: 'var(--ink-soft)',     label: 'Maîtrise' },
  }.freeze

  def cefr_colors(level)
    CEFR_COLORS[level] || CEFR_COLORS['A1']
  end

  # Cores das compétences (CO/CE/EE) — mapeamento já documentado em
  # docs/design_system.html, seção "Habilidades", nunca ligado a nenhuma
  # tela até agora.
  COMPETENCIA_COLORS = {
    'CO' => { bg: 'var(--sky-tint)',     text: 'var(--sky)',         border: 'var(--sky-border)',     bar: 'var(--sky)',     emoji: '🎧', label: 'Compréhension Orale' },
    'CE' => { bg: 'var(--amber-tint)',   text: 'var(--amber-ink)',   border: 'var(--amber)',          bar: 'var(--amber)',   emoji: '📖', label: 'Compréhension Écrite' },
    'EE' => { bg: 'var(--success-tint)', text: 'var(--success-deep)', border: 'var(--success-border)', bar: 'var(--success)', emoji: '✍️', label: 'Expression Écrite' },
  }.freeze

  def competencia_colors(code)
    COMPETENCIA_COLORS[code]
  end

  # Cores dos badges de percurso professionnel (OPCO/eCPF).
  PROFESSIONAL_COLORS = {
    'OPCO' => { bg: 'var(--info-tint)',   text: 'var(--info-deep)',   border: 'var(--info)' },
    'eCPF' => { bg: 'var(--violet-tint)', text: 'var(--violet-deep)', border: 'var(--violet)' },
  }.freeze

  def professional_colors(type)
    PROFESSIONAL_COLORS[type]
  end

  # Formata minutos de formação em "Xh YYmin" (ou "YYmin", ou "—" se ausente).
  def format_training_duration(minutes)
    return '—' if minutes.blank? || minutes.zero?

    hours = minutes / 60
    mins = minutes % 60
    hours.positive? ? "#{hours}h #{format('%02d', mins)}min" : "#{mins}min"
  end

  # Capa do card de atividade: imagem, thumbnail do YouTube ou gradiente com ícone.
  # (Versão FR: aqui as mídias são colunas de URL — imagem_url / video_url.)
  def activity_cover(activity)
    if activity.imagem_url.present?
      { type: :image, url: activity.imagem_url }
    elsif activity.video_url.present?
      yt = activity.video_url.match(/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/)
      yt ? { type: :image, url: "https://img.youtube.com/vi/#{yt[1]}/hqdefault.jpg" } : { type: :gradient, icon: 'bi-play-circle' }
    elsif activity.texto.present? || activity.texte.present?
      { type: :gradient, icon: 'bi-journal-text' }
    else
      { type: :gradient, icon: 'bi-pencil-square' }
    end
  end

  # Total de exercícios da atividade (a view antiga esquecia as associações
  # de colunas — por isso alguns cards mostravam "0 questions").
  # .size (não .count): usa o array já carregado quando o controller faz
  # .includes(...) nessas associações, em vez de bater 5 queries por
  # atividade sempre que essa helper é chamada dentro de um .each.
  def activity_exercise_count(activity)
    activity.questions.size +
      activity.fill_blanks.size +
      activity.sentence_orderings.size +
      activity.paragraph_orderings.size +
      activity.column_associations.size
  end
end
