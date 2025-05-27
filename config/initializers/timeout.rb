# Configuração de timeout baseada na experiência do app de português
# Previne timeouts em produção com atividades grandes

# Configuração simplificada para evitar problemas de compatibilidade
if Rails.env.production?
  Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout
end

# Configuração específica para produção
if Rails.env.production?
  # Timeout mais agressivo em produção
  Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout,
    service_timeout: 25,  # 25 segundos para processamento
    wait_timeout: 5,      # 5 segundos para esperar na fila
    wait_overtime: 5      # 5 segundos extras
end

# Middleware customizado para detectar atividades grandes
class ActivityTimeoutMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    
    # Verificar se é uma requisição de criação/atualização de atividade
    if activity_request?(request)
      # Adicionar header para timeout estendido
      env['HTTP_X_TIMEOUT_OVERRIDE'] = '60' # 60 segundos para atividades
    end
    
    @app.call(env)
  end

  private

  def activity_request?(request)
    request.path.include?('/activities') && 
    (request.post? || request.patch? || request.put?)
  end
end

# Adicionar middleware apenas em produção
if Rails.env.production?
  Rails.application.config.middleware.use ActivityTimeoutMiddleware
end 