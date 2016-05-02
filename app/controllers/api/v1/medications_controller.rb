module Api::V1
  class MedicationsController < ApiController
    before_action :check_owner_or_doctor, only: [:index]
    before_action :check_owner, except: [:index]

    include MedicationsCommon

    def index
      user_id = params[:user_id]
      user = User.find(user_id)
      @medications = user.medications
      if params[:source]
        @medications = @medications.where(source: params[:source])
      end
      @medications = @medications.order(date: :desc)
      if params[:limit]
        @medications = @medications.limit(params[:limit].to_i)
      end

      render :template => 'medications/index.json'
    end
  end
end
