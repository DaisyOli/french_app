# config/initializers/rack_attack.rb

class Rack::Attack
  # Enable rack-attack
  Rack::Attack.enabled = Rails.env.production?

  # Configure Redis for rate limiting (fallback to memory store in development)
  if Rails.env.production?
    Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"))
  end

  # Throttle login attempts by email address
  throttle('logins/email', limit: 5, period: 20.minutes) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.params['user']['email'].to_s.downcase.gsub(/\s+/, "")
    end
  end

  # Throttle login attempts by IP address
  throttle('logins/ip', limit: 10, period: 20.minutes) do |req|
    if req.path == '/users/sign_in' && req.post?
      req.ip
    end
  end

  # Throttle student login attempts
  throttle('student_logins/email', limit: 5, period: 20.minutes) do |req|
    if req.path == '/students/sign_in' && req.post?
      req.params['student']['email'].to_s.downcase.gsub(/\s+/, "")
    end
  end

  # General request throttling by IP
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  # Throttle password reset requests
  throttle('password_resets/email', limit: 3, period: 1.hour) do |req|
    if req.path == '/users/password' && req.post?
      req.params['user']['email'].to_s.downcase.gsub(/\s+/, "")
    end
  end

  # Block suspicious requests
  blocklist('block_bad_user_agents') do |req|
    req.user_agent =~ /curl|wget|python|ruby|java|php/i
  end

  # Allow localhost in development
  safelist('allow_localhost') do |req|
    req.ip == '127.0.0.1' || req.ip == '::1' unless Rails.env.production?
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    retry_after = (env['rack.attack.match_data'] || {})[:period]
    [
      429,
      {
        'Content-Type' => 'application/json',
        'Retry-After' => retry_after.to_s
      },
      [{ error: 'Too many requests. Please try again later.' }.to_json]
    ]
  end
end 