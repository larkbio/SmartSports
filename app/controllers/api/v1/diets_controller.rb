module Api::V1
  class DietsController < ApiController
    before_action :set_diet, only: [:update, :destroy]
    before_action :check_owner_or_doctor

    include DietsCommon

    def index
      user_id = params[:user_id]
      user = User.find(user_id)
      @diets = user.diets
      if params[:source]
        @diets = @diets.where(source: params[:source])
      end
      @diets = @diets.order(date: :desc)
      if params[:limit]
        @diets = @diets.limit( params[:limit].to_i )
      end

      render :template => '/diets/index.json'
    end
  end
end
