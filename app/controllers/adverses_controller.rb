class AdversesController < ApplicationController
  before_action :check_owner_or_doctor

  include AdversesCommon

  # GET /activities
  # GET /activities.json
  def index
    user_id = params[:user_id]
    @adverses = Adverse.where(user_id: user_id).order("time desc, created_at desc")
  end

end
