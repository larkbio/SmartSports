module Api::V1
  class ActivitiesController < ApiController
    before_action :set_activity, only: [ :update, :destroy]
    before_action :check_owner_or_doctor

    include ActivitiesCommon

    def index
      user_id = params[:user_id]
      user = User.find(user_id)
      @activities = user.activities
      if params[:source]
        @activities = @activities.where(source: params[:source])
      end
      @activities = @activities.order(start_time: :desc)
      if params[:limit]
        @activities = @activities.limit(params[:limit].to_i)
      end

      render :template => "/activities/index.json"
    end

  end

end
