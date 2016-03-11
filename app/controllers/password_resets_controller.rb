class PasswordResetsController < ApplicationController
  skip_before_filter :require_login
  before_action :set_locale
  layout :resolve_layout

  include PasswordResetsCommon

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end
    # the next line makes the password confirmation validation work
    @user.password_confirmation = params[:user][:password_confirmation]
    # the next line clears the temporary token and updates the password
    begin
      if @user.change_password!(params[:user][:password])
        #redirect_to(root_path, :notice => 'Password was successfully updated.')
        render json: {:ok => true, :locale => I18n.locale, :msg => I18n.translate('password_change_success')}
      else
        key = @user.errors.values[0]
        message = (I18n.translate(key))
        # render :action => "edit", :notice => message
        render json: {:ok => false, :locale => I18n.locale, :msg => message}
      end
    rescue => e
      logger.info "Exception"
      logger.error e
      logger.error e.backtrace.join("\n")
      #redirect_to(root_path, :notice => 'Failed to send email.')
      render json: {:ok => false, :locale => I18n.locale}
    end
  end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])
    if @user.blank?
      not_authenticated
      return
    end
  end

  private

  def resolve_layout
    case action_name
    when "edit"
      "auth"
    else
      "application"
    end
  end

end
