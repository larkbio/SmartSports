Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_assets = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = true

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # config.assets.precompile += %w( search.js )

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  app_config_fname = '/data/.smartdiab_app_config'
  if not File.exists?(app_config_fname)
    raise "Smartdiab app configuration file "+app_config_fname+" does not exist."
  end
  APP_CONFIG = YAML.load_file(app_config_fname)[::Rails.env]
  APP_CONFIG['PAPERCLIP_PATH'] = ":rails_root/system/:class/:attachment/:id/:style/:basename.:extension"

  connection_config_fname = "/data/.smartdiab_connection_config.yml"
  if not File.exists?(connection_config_fname)
    raise "Connections configuration file "+connection_config_fname+" does not exist."
  end
  CONNECTION_CONFIG = YAML.load_file(connection_config_fname)[::Rails.env]

  mail_config_fname =  File.join('/data/.mail.conf')
  if not File.exists?(mail_config_fname)
    raise "Configuration file "+mail_config_fname+" does not exist."
  end
  MAIL_CONFIG = YAML.load_file(mail_config_fname)[::Rails.env]

  db_config_fname = '/data/.db.conf'
  if not File.exists?(db_config_fname)
    raise "Configuration file "+db_config_fname+" does not exist."
  end
  DB_CONFIG = YAML.load_file(db_config_fname)[::Rails.env]

  DB_EN_CONFIG=YAML.load_file(File.join(Rails.root, 'config', 'locales', 'databases.en.yml'))['en']
  DB_HU_CONFIG=YAML.load_file(File.join(Rails.root, 'config', 'locales', 'databases.hu.yml'))['hu']
  CONFIG_PARAMS={
      hu: YAML.load_file(File.join(Rails.root, 'config', 'locales', 'databases.hu.yml'))['hu'],
      en: YAML.load_file(File.join(Rails.root, 'config', 'locales', 'databases.en.yml'))['en']
  }
  config.action_mailer.default_url_options = {
      :host => 'app.smartdiab.com'
  }

  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  # SMTP settings for gmail
  config.action_mailer.smtp_settings = {
      :domain => 'smartdiab.com',
      :address              => MAIL_CONFIG['host'],
      :port                 => 587,
      :enable_starttls_auto => true
  }

  Paperclip.options[:command_path] = "/usr/bin/"

  DATA_DIR =  File.path('/data/projects/SmartSports-local/hr_data')
  if not File.exists?(DATA_DIR)
    raise "Data dir '#{DATA_DIR}' missing"
  end
end
