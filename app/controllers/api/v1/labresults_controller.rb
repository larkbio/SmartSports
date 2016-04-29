module Api::V1
  class LabresultsController < ApiController
    before_action :check_owner_or_doctor

    include LabresultsCommon

    def index
      lim = 10
      if params[:limit]
        lim = params[:limit].to_i
      end

      user_id = params[:user_id]
      user = User.find(user_id)
      hist = user.labresults.order(created_at: :desc).limit(lim)
      render json: hist
    end

  end
end
