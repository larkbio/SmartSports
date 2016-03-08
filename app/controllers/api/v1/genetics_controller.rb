module Api::V1
  class GeneticsController < ApiController

    include GeneticsCommon

    def index
      lim = 10
      if params[:limit]
        lim = params[:limit].to_i
      end
      user_id = params[:user_id]

      if current_resource_owner.id != user_id.to_i
        render json: nil, status: 403
        return
      end

      user = User.find(user_id)
      hist = user.genetics.order(created_at: :desc).limit(lim)
      render json: hist
    end

  end
end
