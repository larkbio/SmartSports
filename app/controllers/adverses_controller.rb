class AdversesController < ApplicationController
  before_action :set_activity, only: [:show, :edit, :update, :destroy]
  before_action :check_owner_or_doctor

  include AdversesCommon

  # GET /activities
  # GET /activities.json
  def index
    user_id = params[:user_id]
    @adverses = Adverse.where(user_id: user_id)
  end

end
