namespace :students do
  desc "Populate streak data for existing students based on their activity history"
  task populate_streaks: :environment do
    puts "Populando dados de streak para estudantes existentes..."
    
    Student.find_each do |student|
      puts "Processando estudante ID: #{student.id}"
      
      # Buscar todas as atividades completadas ordenadas por data
      completed_activities = student.completed_activities
                                   .order(:created_at)
                                   .pluck(:created_at)
                                   .map(&:to_date)
                                   .uniq
      
      if completed_activities.empty?
        puts "  - Nenhuma atividade encontrada"
        next
      end
      
      # Calcular streak atual
      current_streak = 0
      best_streak = 0
      last_date = nil
      temp_streak = 0
      
      # Calcular streak histórico
      completed_activities.each do |date|
        if last_date.nil? || date == last_date + 1.day
          temp_streak += 1
        else
          best_streak = [best_streak, temp_streak].max
          temp_streak = 1
        end
        last_date = date
      end
      
      best_streak = [best_streak, temp_streak].max
      
      # Calcular streak atual (desde a última atividade até hoje)
      if completed_activities.last == Date.current
        # Se fez atividade hoje, calcular streak reverso
        current_date = Date.current
        current_streak = 0
        
        completed_activities.reverse.each do |date|
          if date == current_date
            current_streak += 1
            current_date -= 1.day
          else
            break
          end
        end
      elsif completed_activities.last == Date.current - 1.day
        # Se fez atividade ontem, calcular streak reverso
        current_date = Date.current - 1.day
        current_streak = 0
        
        completed_activities.reverse.each do |date|
          if date == current_date
            current_streak += 1
            current_date -= 1.day
          else
            break
          end
        end
      else
        # Quebrou o streak
        current_streak = 0
      end
      
      # Atualizar dados do estudante
      student.update!(
        current_streak: current_streak,
        best_streak: best_streak,
        last_activity_date: completed_activities.last
      )
      
      puts "  - Streak atual: #{current_streak}, Melhor streak: #{best_streak}"
    end
    
    puts "Concluído!"
  end

end
