module Api::V1
  class MeasurementsController < ApiController
    before_action :set_measurement, only: [ :update, :destroy]
    before_action :check_owner_or_doctor
    include MeasurementsCommon

    def index
      user_id = params[:user_id]
      if current_resource_owner.id != user_id.to_i
        render json: nil, status: 403
        return
      end

      user = User.find(user_id)
      @measurements = user.measurements
      if(params[:source])
        @measurements = @measurements.where(source: params[:source])
      end
      if(params[:from_date])
        @measurements = @measurements.where("date >= ?", params[:source])
      end
      if params[:limit]
        @measurements = @measurements.limit(params[:limit].to_i)
      end
      @measurements = @measurements.order(date: :desc)

      render :template => "/measurements/index.json"
    end
  end
end
