# require "smtp_tls"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  config_fname = ENV['HOME']+'/.smartsport_connection_data'
  if not File.exists?(config_fname)
    raise "Connections configuration file "+config_fname+" does not exist."
  end
  APP_CONFIG = YAML.load_file(config_fname)[::Rails.env]

  mail_config_fname =  File.join(ENV['HOME'], '.mail.conf')
  if not File.exists?(mail_config_fname)
    raise "Configuration file "+mail_config_fname+" does not exist."
  end
  MAIL_CONFIG = YAML.load_file(mail_config_fname)[::Rails.env]

  config.action_mailer.default_url_options = {
      :host => 'localhost',
      :port => 3000
  }

  # config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  # config.action_mailer.logger = nil

  # config.action_mailer.debug_output = $stdout
  config.action_mailer.smtp_settings = {
      :domain => 'smartsport.me',
      :address              => MAIL_CONFIG['host'],
      :port                 => 465,
      :user_name            => MAIL_CONFIG['user'],
      :password             => MAIL_CONFIG['password'],
      :authentication       => :plain,
      :ssl => true,
      :openssl_verify_mode => 'none',
      # :enable_starttls_auto => true
  }

end
