module Api::V1
  class AdversesController < ApiController
    before_action :check_owner_or_doctor, only: [:index]
    before_action :check_owner, except: [:index]

    include AdversesCommon

    def index
      user_id = params[:user_id]
      @adverses = Adverse.where(user_id: user_id)
      render :template => '/adverses/index.json'
    end

  end
end
