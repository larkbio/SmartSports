class PagesController < ApplicationController
  include DashboardHelper

  before_action :set_locale
  before_action :set_user_data
  before_action :set_db_version
  before_filter :require_login, except: [:signin, :signup, :reset_password]
  layout :which_layout

  @movesconn = nil
  @withingsconn = nil
  @fitbitconn = nil
  @googleconn = nil

  include SaveClickRecord

  # login/register, resetpw
  def reset_password

  end

  def signup
  end

  def signin
    # browser_locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    # logger.debug "browser locale: #{browser_locale}"
    # I18n.locale = browser_locale || I18n.default_locale
    @user = User.new

    @lang_label = 'hu'
    if I18n.locale.to_s=='hu'
      @lang_label = 'en'
    end
  end

  def main
    loc = I18n.default_locale
    lang = current_user.try(:profile).try(:default_lang)
    if lang
      loc = lang.to_sym
    end
    if SmartSports::SHOW_DOCTOR and current_user.doctor?
      redirect_to pages_md_patients_path(locale: loc)
    else
      redirect_to pages_dashboard_path(locale: loc)
    end
  end

  def adverse
    @adverses = current_user.adverses.order(time: :desc)
  end

  def dashboard
    @measurements = current_user.measurements.where(source: @default_source).order(date: :desc).limit(4)
    get_todays_summary()
    # u.summaries.where(group: 'walking').where("date between ? and ?", DateTime.now.at_beginning_of_month, DateTime.now)
    save_click_record(:success, nil, nil)
  end

  def health
    @activity = Summary.new
    @measurement = Measurement.new
    @measurements = current_user.measurements.where(:source => [@default_source, 'demo']).order(created_at: :desc).limit(4)
    save_click_record(:success, nil, nil)
  end

  def exercise
    @uid = current_user.id
    @conn = current_user.connections
    @activities = current_user.activities.where(source: @default_source).order(created_at: :desc).limit(4)
    @intensity_values = Activity.intensity_values
    save_click_record(:success, nil, nil)
    # respond_to do |format|
    #   format.html
    #   format.json
    # end
    # render :text => "<pre>"+request.env["omniauth.auth"].to_yaml+"</pre>"
  end

  def explore
    user = nil
    if params[:user_id]
      user_id = params[:user_id].to_i
      user = User.where("id = #{user_id}").first
    end
    if user.nil?
      user = current_user
    end
    @sensor_measurements = user.sensor_measurements.order(start_time: :desc)
    save_click_record(:success, nil, nil)
  end

  def diet
    @diets = current_user.diets.where(source: @default_source).order(created_at: :desc).limit(4)
    save_click_record(:success, nil, nil)
  end

  def medication
    @insulin_types = MedicationType.where(:group => "insulin")
    @oral_medication_types = MedicationType.where(:group => "oral")
    @medications = current_user.medications.order(created_at: :desc).limit(4)
    save_click_record(:success, nil, nil)
  end

  def lifestyle
    @lifestyles = current_user.lifestyles.order(created_at: :desc).limit(4)
    @titles = JSON.generate({sleep: t(:sleep), stress: t(:stress), illness: t(:illness), pain: t(:pain), period: t(:period)})
    save_click_record(:success, nil, nil)
  end

  def genetics
    @personal_records = current_user.personal_records.order(created_at: :desc).limit(4)
    save_click_record(:success, nil, nil)
  end

  def labresult
    save_click_record(:success, nil, nil)
  end

  def faq
    faqLang = I18n.locale
    faqLang ||= 'en'
    @faqs = Faq.where(lang: faqLang)
    puts @faqs
    # save_click_record(:success, nil, nil)
  end

  def analytics
    save_click_record(:success, nil, nil)
    if params[:user_id] && current_user.admin?
      @selected_user = User.find_by_id(params[:user_id])
    end
  end

  def md_statistics
    save_click_record(:success, nil, nil)
    if params[:user_id] && current_user.admin?
      @selected_user = User.find_by_id(params[:user_id])
    end
  end

  def customforms
    @icons = CustomForm.icons
    @custom_forms = current_user.custom_forms.order(order_index: :desc)
    @form_list = CustomForm.form_list
    @form_params = CustomForm.form_params
    @hidden_forms = true
  end

  def md_patients
  end

  def md_customforms
    @icons = CustomForm.icons
    @custom_forms = current_user.custom_forms.order(order_index: :desc)
    @form_list = CustomForm.form_list
    @form_params = CustomForm.form_params
    @hidden_forms = true
  end

  def admin_doctors
    if !current_user.admin
      redirect_to :controller => 'pages', :action => 'error', :locale => I18n.locale
      return
    end
    @doctors = User.where(doctor: true)
  end

  def admin
    if !current_user.admin
      redirect_to :controller => 'pages', :action => 'error', :locale => I18n.locale
      return
    end

    @users = User.all
    @profiles = Profile.all
    # startTime=(DateTime.now+1.day).beginning_of_day-1.week
    # @clickrecords = ClickRecord.where("created_at >= :start_date", {start_date: startTime}).group('user_id').order('count_id desc').count('id')
    @clickrecords = ClickRecord.all.group('user_id').order('count_id desc').count('id')
  end

  def moves
    @movesconn = Connection.where(user_id: current_user.id, name: 'moves').first
    if @movesconn
      @active_since_moves = @movesconn.created_at
      @last_sync_date_moves = get_last_synced_date(current_user.id, "moves")
    end
  end

  def withings
    @withingsconn = Connection.where(user_id: current_user.id, name: 'withings').first
    if @withingsconn
      @active_since_withings = @withingsconn.created_at
      @last_sync_date_withings = get_last_synced_date(current_user.id, "withings")
    end
  end

  def fitbit
    @fitbitconn = Connection.where(user_id: current_user.id, name: 'fitbit').first
    if @fitbitconn
      @active_since_fitbit = @fitbitconn.created_at
      @last_sync_date_fitbit = get_last_synced_date(current_user.id, "fitbit")
    end
  end

  def googlefit
    @googleconn = Connection.where(user_id: current_user.id, name: 'google').first
    if @googleconn
      @active_since_google = @googleconn.created_at
      @last_sync_date_google = get_last_synced_date(current_user.id, "google")
    end
  end

  def misfit
    @misfitconn = Connection.where(user_id: current_user.id, name: 'misfit').first
    if @misfitconn
      @active_since_misfit = @misfitconn.created_at
      @last_sync_date_misfit = get_last_synced_date(current_user.id, "misfit")
    end
  end

  def profile
    @user = current_user
    if @user.profile.nil?
      @user.profile = Profile.create()
    end
    @profile = @user.profile
    save_click_record(:success, nil, nil)
  end

  def traffic()
    uid = params[:usid]
    startTime=(DateTime.now+1.day).beginning_of_day-1.week
    email = nil
    if uid
      crs = ClickRecord.where("created_at >= :start_date AND user_id = :uid", {start_date: startTime, uid: uid})
      email = User.where(id: uid)[0].email
    else
      crs = ClickRecord.where("created_at >= :start_date", {start_date: startTime})
    end
    visits = Array.new(168)
    first = startTime
    (0..167).each do |i|
      visits[i] = [i+1, first,0]
      first = first+1.hour
    end
    arr = crs.group_by{ |u|
      u.created_at.beginning_of_hour
    }
    arr = arr.collect{ |it| [(it[0].strftime("%s").to_i-startTime.strftime("%s").to_i)/60/60, it[0],it[1].length]}
    arr.each{ |it|
      visits[it[0]-2][2] = it[2]
    }
    @visits = visits.to_json
    render json: {  data: visits.to_json , email: email, :status => "OK"}
  end

  def error
    # to display some error in case of app failure
  end

  def connections
    @connections = Connection.where(user_id: current_user.id)
    @add_conn = params[:addconn] unless params[:addconn].nil?
  end

  def friendship
    @friendship = Friendship.new
  end

private

  def which_layout
    if action_name=='signin' || action_name=='signup' || action_name=='reset_password'
      'auth'
    else
      'pages'
    end
  end

  def get_shown_user(params)
    failed = false
    shown_user_id = params[:shown_user].to_i
    shown_user = nil
    if shown_user_id == current_user.id
      failed = true
    end

    if not failed and shown_user_id>0
      q = User.where("id = #{shown_user_id}")
      if q.size != 1
        failed = true
        logger.info "Invalid user id "+shown_user_id.to_s
      else
        shown_user = q.first()
      end
    end

    if not failed and shown_user
      if not shown_user.is_friend?(current_user.id)
        failed = true
        logger.info "Unauth user id "+shown_user_id.to_s
      end
    end

    if not shown_user
      shown_user = current_user
    end

    return shown_user
  end

  def set_user_data
    @display_name = ""
    if current_user
      user_reg_date = current_user.created_at.to_date
      user_reg_days = (DateTime.now.to_date-user_reg_date).to_i
      @user_info = [user_reg_date, user_reg_days]
      @display_name = current_user.name
      prf = current_user.profile
      if (!prf.nil?) && (!prf.firstname.nil? || !prf.lastname.nil?) && (prf.firstname!='' || prf.lastname!='')
        @display_name = prf.firstname+' '+prf.lastname
        if I18n.locale && I18n.locale.to_s=='hu'
          @display_name = prf.lastname+' '+prf.firstname
        end
      end
    end
    @values = JSON.dump(I18n.t :popupmessages)
  end

  def set_db_version
    if InitVersion.all.size == 1
      @dbversion = InitVersion.last.version_number
    else
      @dbversion = 1
    end
  end

end
