# config/initializers/rack_attack.rb

class Rack::Attack
  # Enable rack-attack
  Rack::Attack.enabled = Rails.env.production?

  # Configure Redis para rate limiting com pool otimizado
  if Rails.env.production?
    redis_config = {
      url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"),
      pool_size: 5, # Pool menor para Rack::Attack
      pool_timeout: 5,
      reconnect_attempts: 2,
      connect_timeout: 3,
      read_timeout: 5,
      write_timeout: 3
    }
    
    Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
      redis_config.merge(
        namespace: "rack_attack",
        expires_in: 1.hour
      )
    )
  end

  # Throttle mais inteligente para login - reduzir janela de tempo
  throttle('logins/email', limit: 5, period: 10.minutes) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.params['user']['email'].to_s.downcase.gsub(/\s+/, "")
    end
  end

  # Throttle login attempts by IP - reduzir janela
  throttle('logins/ip', limit: 10, period: 10.minutes) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.ip
    end
  end

  # Throttle student login attempts - reduzir janela
  throttle('student_logins/email', limit: 5, period: 10.minutes) do |req|
    if req.path == '/students/sign_in' && req.post?
      req.params['student']['email'].to_s.downcase.gsub(/\s+/, "")
    end
  end

  # Rate limiting mais conservador para requisições gerais
  throttle('req/ip', limit: 200, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets') || req.path.start_with?('/health')
  end

  # Throttle password reset requests - janela menor
  throttle('password_resets/email', limit: 3, period: 30.minutes) do |req|
    if req.path == '/users/password' && req.post?
      req.params['user']['email'].to_s.downcase.gsub(/\s+/, "")
    end
  end

  # Block suspicious requests - mais específico
  blocklist('block_bad_user_agents') do |req|
    req.user_agent =~ /curl|wget|python-requests|ruby|java|php|bot/i
  end

  # Allow localhost e health checks
  safelist('allow_localhost_and_health') do |req|
    req.ip == '127.0.0.1' || req.ip == '::1' || req.path.start_with?('/health') unless Rails.env.production?
  end

  # Custom response for throttled requests - mais eficiente
  self.throttled_responder = lambda do |env|
    retry_after = (env['rack.attack.match_data'] || {})[:period]
    [
      429,
      {
        'Content-Type' => 'application/json',
        'Retry-After' => retry_after.to_s,
        'Cache-Control' => 'no-cache'
      },
      [{ error: 'Muitas tentativas. Tente novamente em alguns minutos.' }.to_json]
    ]
  end
end 