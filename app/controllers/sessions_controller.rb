class SessionsController < ApplicationController
  respond_to :json
  skip_before_filter :require_login, except: [:destroy]

  def create
    @user = login(params[:email], params[:password])
    if @user
      save_click_record(:success, nil, "login", request.remote_ip)
        if @user.has_profile && @user.profile.default_lang
          I18n.locale = @user.profile.default_lang
          redir_url = redir_url = root_path
        else
          redir_url = pages_profile_path(I18n.locale)
        end

        render json: { :ok => true, :msg => 'login_succ', :locale => I18n.locale, :profile => @user.has_profile, :redir_url => redir_url}
    else
      u = User.find_by_email(params[:email])
      if u
        save_click_record(:failure, nil, "login", request.remote_ip, u)
        message = (I18n.t :error_login_password)
      else
        message = (I18n.t :error_login_username)
        logger.debug "Login failed from #{request.remote_ip}"
      end

      render json: { :ok => false, :msg => message}, status: 403
    end
  end

  def signout
    save_click_record(:success, nil, "logout")
    logout
    render json: { :ok => true, :msg => 'logout_succ'}
  end
end
