class Student < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :validatable

  has_many :completed_activities, dependent: :destroy
  has_many :completed_activity_records, through: :completed_activities, source: :activity
  has_many :activity_ratings, dependent: :destroy

  CEFR_LEVELS = %w[A1 A2 B1 B2 C1 C2].freeze

  validates :nível, inclusion: { in: CEFR_LEVELS }, allow_blank: true

  # Quais níveis de atividade este aluno pode acessar — cumulativo, o nível
  # atribuído e tudo abaixo (mesma regra do practice-br). Sem nível definido
  # (aluno antigo, de antes desta coluna existir, ou convite sem nível
  # escolhido) = acesso total, pra não travar quem já usava o app.
  def accessible_levels
    return CEFR_LEVELS if nível.blank?

    idx = CEFR_LEVELS.index(nível)
    idx ? CEFR_LEVELS[0..idx] : CEFR_LEVELS
  end

  # Atualizar streak após completar uma atividade
  def update_streak!
    today = Date.current
    
    if last_activity_date.nil?
      # Primeira atividade
      self.current_streak = 1
      self.last_activity_date = today
    elsif last_activity_date == today
      # Já fez atividade hoje, não muda o streak
      return
    elsif last_activity_date == today - 1.day
      # Dia consecutivo
      self.current_streak += 1
      self.last_activity_date = today
    else
      # Quebrou a sequência
      self.current_streak = 1
      self.last_activity_date = today
    end
    
    # Atualizar melhor streak se necessário
    self.best_streak = [best_streak, current_streak].max
    
    save!
  end

  # Determinar troféu atual baseado no streak
  def current_trophy
    case current_streak
    when 0..2
      { name: "Débutant", icon: "🎯", description: "Commencez votre aventure!" }
    when 3..6
      { name: "Croissant", icon: "🥐", description: "3 jours consécutifs!" }
    when 7..13
      { name: "Baguette", icon: "🥖", description: "1 semaine de régularité!" }
    when 14..29
      { name: "Fromage", icon: "🧀", description: "2 semaines d'assiduité!" }
    when 30..59
      { name: "Vin", icon: "🍷", description: "1 mois de persévérance!" }
    else
      { name: "Tour Eiffel", icon: "🗼", description: "Maître de l'assiduité!" }
    end
  end

  # Próximo troféu e progresso
  def next_trophy_info
    case current_streak
    when 0..2
      { target: 3, name: "Croissant", icon: "🥐", progress: current_streak, needed: 3 - current_streak }
    when 3..6
      { target: 7, name: "Baguette", icon: "🥖", progress: current_streak, needed: 7 - current_streak }
    when 7..13
      { target: 14, name: "Fromage", icon: "🧀", progress: current_streak, needed: 14 - current_streak }
    when 14..29
      { target: 30, name: "Vin", icon: "🍷", progress: current_streak, needed: 30 - current_streak }
    when 30..59
      { target: 60, name: "Tour Eiffel", icon: "🗼", progress: current_streak, needed: 60 - current_streak }
    else
      { target: current_streak, name: "Maximum", icon: "👑", progress: current_streak, needed: 0 }
    end
  end

  # Mensagem motivacional baseada no streak
  def motivational_message
    case current_streak
    when 0
      "Commencez votre aventure française aujourd'hui!"
    when 1
      "Excellent début! Continuez demain!"
    when 2
      "Bravo! Un jour de plus pour votre croissant 🥐"
    when 3..6
      "Fantastique! Vous avez gagné votre croissant! 🥐"
    when 7..13
      "Magnifique! Votre baguette vous attend! 🥖"
    when 14..29
      "Incroyable! Le fromage est à vous! 🧀"
    when 30..59
      "Exceptionnel! Savourez votre vin! 🍷"
    else
      "Légendaire! Vous maîtrisez l'art français! 🗼"
    end
  end
end
