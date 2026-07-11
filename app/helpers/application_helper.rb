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
  def activity_exercise_count(activity)
    activity.questions.count +
      activity.fill_blanks.count +
      activity.sentence_orderings.count +
      activity.paragraph_orderings.count +
      activity.column_associations.count
  end
end
