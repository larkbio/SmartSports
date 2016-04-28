class DietsController < ApplicationController
  before_action :set_diet, only: [:edit, :update, :destroy]
  before_action :check_owner_or_doctor

  include DietsCommon

  # GET /diets
  # GET /diets.json
  def index
    user_id = params[:user_id]
    source = params[:source]

    order = params[:order]
    limit = params[:limit]

    favourites = params[:favourites]

    @diets = Diet.where("user_id = #{user_id}")
    if source
      @diets = @diets.where("source = '#{source}'")
    end
    if order and order=="desc"
      @diets = @diets.order(date: :desc)
    else
      @diets = @diets.order(date: :asc)
    end
    if limit and limit.to_i>0
      @diets = @diets.limit(limit)
    end

    if params[:year] and params[:month]
      year = params[:year].to_i
      month = params[:month].to_i
      numdays = Time.days_in_month(month, year)
      from = "#{year}-#{month}-01 00:00:00"
      to = "#{year}-#{month}-#{numdays} 23:59:59"
      @diets = @diets.where("date between '#{from}' and '#{to}'")
    end

    if favourites and favourites == "true"
      @diets = @diets.where(favourite: true)
    end

    respond_to do |format|
      format.html
      format.json
      format.js
    end
  end

  def show
    set_diet
  end

end
