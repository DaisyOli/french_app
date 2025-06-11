# Configuração otimizada do Redis para produção
if Rails.env.production?
  redis_config = {
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"),
    pool_size: ENV.fetch("REDIS_POOL_SIZE", 10).to_i,
    pool_timeout: 5,
    reconnect_attempts: 3,
    reconnect_delay: 1,
    reconnect_delay_max: 5,
    connect_timeout: 5,
    read_timeout: 10,
    write_timeout: 5
  }

  # Configurar Redis para cache
  Rails.application.config.cache_store = :redis_cache_store, redis_config.merge(
    namespace: "french_app_cache",
    expires_in: 1.hour # TTL padrão para reduzir acúmulo
  )

  # Configurar Redis para Action Cable com pool menor
  ActionCable.server.config.cable = {
    adapter: "redis",
    url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1"),
    channel_prefix: "french_app_#{Rails.env}"
  }
end

# Monitoramento de conexões Redis em produção
if Rails.env.production?
  Rails.application.config.after_initialize do
    Rails.logger.info "Redis configurado com pool de #{redis_config[:pool_size]} conexões"
  end
end 