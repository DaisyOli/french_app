require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FrenchApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Set default locale to French
    config.i18n.default_locale = :fr
    config.i18n.available_locales = [:fr]
    config.i18n.fallbacks = [:fr]

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    
    # Security middleware
    config.middleware.use Rack::Attack
    
    # Force SSL in production
    config.force_ssl = Rails.env.production?
    
    # Configure session security
    config.session_store :cookie_store, 
      key: '_french_app_session',
      secure: Rails.env.production?,
      httponly: true,
      same_site: :lax
  end
end
