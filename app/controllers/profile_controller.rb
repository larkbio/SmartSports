class ProfileController < ApplicationController
  before_action :set_profile, only: [:show, :edit]
  before_action :set_locale
  layout :which_layout

  def index
  end

  def new
    @values = JSON.dump(I18n.t :popupmessages)
    @profile = Profile.new
  end

  def edit
  end

  def show
  end

  def create
    @profile = Profile.new(profile_params)
    if !profile_params['sex']
      @profile.sex = "female"
    end
    if !profile_params['smoke']
      @profile.smoke = true
    end
    if !profile_params['insulin']
      @profile.insulin = true
    end

    if profile_params['default_lang']
      I18n.locale = profile_params['default_lang']
    end

    respond_to do |format|
      if @profile.save
        format.json { render json: {:ok => true, locale: I18n.locale} }
      else
        key = @profile.errors.values[0]
        message = (I18n.translate(key))
        format.json { render json: { ok: false, msg: message, locale: I18n.locale}, status: 401 }
      end
    end
  end

  def update
    @profile = Profile.find(params["id"])

    lang = params[:lang]

    respond_to do |format|
      par = params.require(:profile).permit(:id, :user_id, :firstname, :lastname, :height, :weight, :sex, :year_of_birth, :smoke, :insulin, :default_lang)
      if par['default_lang']
        I18n.locale = par['default_lang']
      end
      if @profile.update(par)
        format.json { render json: { :status => "OK", :default_lang_changed => lang!=par['default_lang'], :locale => par['default_lang'], :msg => "Updated successfully" } }
      else
        key = @profile.errors.values[0]
        message = (I18n.translate(key))
        format.json { render json: { :status => "NOK", :locale => I18n.locale, :msg => message } }
      end
    end
  end

  def set_default_lang
    p = current_user.profile
    if p
      p.default_lang = I18n.locale
      p.save!
      render :json => { :status => "OK", locale: I18n.locale, :msg => "Profile update successful"}
      return
    end
    render :json => {:msg => "Profile update error"}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      u_id = params[:user_id]
      @profile = Profile.where(user_id: u_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      params.require(:profile).permit(:user_id, :firstname, :lastname, :weight, :height, :sex, :smoke, :insulin, :year_of_birth, :default_lang)
    end

    def which_layout
      'auth'
    end

end
