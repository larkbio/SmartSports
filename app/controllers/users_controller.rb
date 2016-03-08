class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  skip_before_filter :require_login, only: [:new, :create]

  # GET /users
  # GET /users.json
  def index
    if !current_user.admin? && !current_user.doctor?
      respond_to do |format|
        format.html { redirect_to errors_unauthorized_path }
        format.json { render json: { :status => 'NOK', :msg => 'error_unauthorized' }, status: 403  }
      end
      return
    end
    @users = User.all
    if(params[:doctor])
      @users = @users.where(doctor: true)
    end
  end

  # POST /users
  # POST /users.json
  def create
    if params.fetch("user", {}).fetch("doctor", false)
      if current_user.nil? || !current_user.admin?
        send_error_json("", "Unauthorized", 403)
        return
      else
        # admin user creates a doctor.. create new user; generate random password; send email to new doctor to set pw

        par = user_params
        if User.find_by_email(par['email'])
          send_error_json(par['email'], "doctor_create_fail_email_exists", 401)
          return
        end
        par['password'] = (0...8).map { ('a'..'z').to_a[rand(26)] }.join
        par['password_confirmation'] = par['password']
        @user = User.new(par)
        @user.username = @user.email.split("@")[0]
        @user.name = @user.username

        @user.save!
        @user.generate_reset_password_token!
        url = edit_password_reset_url(id: @user.reset_password_token, locale: I18n.locale)
        Delayed::Job.enqueue InfoMailJob.new(:doctor_invite_email, @user.email, I18n.locale, {reset_url: url})
        send_success_json(@user.id, {email: @user.email, msg: "doctor_invited_msg"})
        return
      end
    end
    @user = User.new(user_params)

    @user.username = @user.email.split("@")[0]
    @user.name = @user.username
    respond_to do |format|
      if @user.save
        mail_lang = params[:lang] || "en"
        Delayed::Job.enqueue InfoMailJob.new(:user_created_email, @user.email, mail_lang, {})

        @user = login(user_params['email'], user_params['password'])

        if @user
          save_click_record(:success, nil, "login", request.remote_ip)
          format.json { render json: {:ok => true, status: 'OK', :msg => 'login_succ', :id => @user.id, :locale => I18n.locale, :profile => @user.has_profile} }
        else
          format.json { render json: {:ok => false, status: 'NOK', :msg => 'login_err'} }
        end

      else
        key = @user.errors.values[0]
        message = (I18n.translate(key))
        format.json { render json: {ok: false, status: 'NOK', msg: message}, status: 401 }
      end
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if !current_user.admin? && !current_user.doctor? && current_user.id != @user.id
      respond_to do |format|
        format.html { redirect_to errors_unauthorized_path }
        format.json { render json: { :status => 'NOK', :msg => 'error_unauthorized' }, status: 403  }
      end
      return
    end
    logger.info "user.show called, calling delayed mail"
    Delayed::Job.enqueue InfoMailJob.new(:user_created_email, current_user.email, "hu", {})
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # TODO is this not needed?
  # def upload
  #   user = User.find(params[:user_id])
  #   user.avatar = params[:avatar]
  #   user.save!
  #   respond_to do |format|
  #     format.html { redirect_to '/pages/mobilepage#settingsPage' }
  #   end
  # end

  def uploadAv
    user = User.find(params[:user_id])
    user.avatar = params[:avatar]
    if user.save
      redirect_to pages_profile_path({:locale => I18n.locale})
    end
  end



  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      par = params.require(:user).permit(:password, :password_confirmation, :name)
      if @user.update(par)
        format.json { render json: {ok: true, status: 'OK', msg: "Updated successfully"} }
      else
        key = @user.errors.values[0]
        message = (I18n.translate(key))
        format.json { render json: {ok: false, status: 'NOK', msg: message} }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    if !current_user.admin || current_user.id==@user.id
      respond_to do |format|
        # format.html { redirect_to errors_unauthorized_path }
        format.json { render json: {:ok => false, :status => 'NOK', :msg => 'error_unauthorized'}, status: 403 }
      end
      return
    end

    @user.destroy
    respond_to do |format|
      # format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { render json: {:ok => true, :status => 'OK'} }
    end
  end


  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    permitted = params.require(:user).permit(:email, :password, :password_confirmation, :name, :avatar, :doctor)
    permitted
  end
end
