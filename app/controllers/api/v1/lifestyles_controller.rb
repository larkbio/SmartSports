module Api::V1
  class LifestylesController < ApiController
    before_action :set_lifestyle, only: [ :update, :destroy]
    before_action :check_owner_or_doctor, only: [:index]
    before_action :check_owner, except: [:index]

    include LifestylesCommon

    def index
      get_lifestyles()
      render :template => '/lifestyles/index.json'
    end
  end
end
