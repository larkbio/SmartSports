class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :edit, :update, :destroy]

  include ActivitiesCommon

  # GET /activities
  # GET /activities.json
  def index
    user_id = params[:user_id]
    source = params[:source]

    order = params[:order]
    limit = params[:limit]

    lang = params[:lang]

    favourites = params[:favourites]

    @activities = Activity.where("user_id = #{user_id}")
    if source
      @activities = @activities.where("source = '#{source}'")
    end
    if order and order=="desc"
      @activities = @activities.order(start_time: :desc)
    else
      @activities = @activities.order(start_time: :asc)
    end
    if limit and limit.to_i>0
      @activities = @activities.limit(limit)
    end

    if params[:year] and params[:month]
      year = params[:year].to_i
      month = params[:month].to_i
      numdays = Time.days_in_month(month, year)
      from = "#{year}-#{month}-01 00:00:00"
      to = "#{year}-#{month}-#{numdays} 23:59:59"
      @activities = @activities.where("date between '#{from}' and '#{to}'")
    elsif params[:date]
      date = params[:date]
      @activities = @activities.where("start_time between '#{date} 00:00:00' and '#{date} 23:59:59'")
    end

    if favourites and favourites == "true"
      @activities = @activities.where(favourite: true)
    end

    for a in @activities
      if a.activity_type
        if lang
          if lang == "hu"
            a.activity = DB_HU_CONFIG['activities'][a.activity_type.name]
          elsif lang == "en"
            a.activity = DB_EN_CONFIG['activities'][a.activity_type.name]
          end
        else
         a.activity = a.activity_type.name
        end
      end
    end

    respond_to do |format|
      format.html
      format.json
      format.csv { send_data @activities.to_csv({}, lang)}
      format.js
    end
  end

  # GET /activities/1
  # GET /activities/1.json
  def show
  end

  # GET /activities/new
  def new
    @activity = Activity.new
    @user = current_user
  end

  # GET /activities/1/edit
  def edit
    @user = current_user
  end

end
