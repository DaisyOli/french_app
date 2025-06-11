# Configuração otimizada do Redis para produção
if Rails.env.production?
  redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/1")
  redis_options = {
    pool_size: ENV.fetch("REDIS_POOL_SIZE", 10).to_i,
    pool_timeout: 5,
    reconnect_attempts: 3,
    connect_timeout: 5,
    read_timeout: 10,
    write_timeout: 5
  }

  # Configurar Redis para cache com URL simples
  Rails.application.config.cache_store = :redis_cache_store, {
    url: redis_url,
    namespace: "french_app_cache",
    expires_in: 1.hour,
    **redis_options
  }

  # Action Cable continua com configuração simples
  ActionCable.server.config.cable = {
    adapter: "redis",
    url: redis_url,
    channel_prefix: "french_app_#{Rails.env}"
  }

  # Log de configuração
  Rails.application.config.after_initialize do
    Rails.logger.info "Redis configurado com pool de #{redis_options[:pool_size]} conexões"
  end
end 