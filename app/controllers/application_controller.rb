class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :require_login
  before_action :set_default_variables

  rescue_from Exception, :with => :general_error_handler

  include RequestHelper
  include AuthHelper

  def general_error_handler(ex)
    logger.error ex.message
    logger.error ex.backtrace.join("\n")
    render 'shared/error'
  end

  private

  def set_locale
    if params[:locale]
      I18n.locale = params[:locale]
    else
      browser_lang = request.env['HTTP_ACCEPT_LANGUAGE']
      if !browser_lang.nil?
        browser_locale = browser_lang.scan(/^[a-z]{2}/).first
        I18n.locale = browser_locale || I18n.default_locale
      end
    end

    @lang_label = 'hu'
    if I18n.locale.to_s=='hu'
      @lang_label = 'en'
    end
  end

  def not_authenticated
     redirect_to "/#{I18n.locale}/pages/signin", alert: "Please login first"
  end

  def set_default_variables
    lang = params[:lang]
    if lang
      I18n.locale=lang
    end

    @default_source = "smartdiab"

    @meas_map = {
        'blood_sugar' => 'bloodglucose',
        'weight' => 'weight40',
        'waist' => 'abdominal40',
        'blood_pressure' => 'bloodpressure40'
    }

    @hidden_forms = false
    
    # request.variant = :tablet if request.user_agent =~ /iPhone/
  end

  def get_last_synced_date(user_id, source)
    last_sync_date = nil
    last_sync = Summary.where(user_id: user_id).where(source: source).order(synced_at: :desc).limit(1)[0]
    if  last_sync
      last_sync_date = last_sync.synced_at
    end
    return last_sync_date
  end


  include SaveClickRecord
  include ResponseHelper


end

