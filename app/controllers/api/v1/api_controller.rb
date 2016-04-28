module Api::V1
  class ApiController < ActionController::Base
    before_action :doorkeeper_authorize!
    before_action :set_default_variables

    rescue_from Exception, :with => :general_error_handler
    respond_to :json

    include RequestHelper
    include ResponseHelper
    include SaveClickRecord
    include ResourceAuthHelper

    def current_resource_owner
      User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
    end

    def general_error_handler(ex)
      logger.error ex.message
      logger.error ex.backtrace.join("\n")
      render json: {msg: ex.message}, status: 400
    end

    private
    def set_default_variables
      @default_source = "smartdiab"

      lang = params[:lang]
      if lang
        I18n.locale=lang
      end

    end
  end
end
