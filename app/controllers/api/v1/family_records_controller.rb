module Api::V1
  class FamilyRecordsController < ApiController
    before_action :check_owner_or_doctor

    include FamilyRecordsCommon

    def index
      lim = 10
      if params[:limit]
        lim = params[:limit].to_i
      end
      user_id = params[:user_id]

      user = User.find(user_id)
      hist = user.family_records.order(created_at: :desc).limit(lim)
      render json: hist
    end

  end
end
