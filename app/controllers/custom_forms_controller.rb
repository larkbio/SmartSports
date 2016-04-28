class CustomFormsController < ApplicationController
  before_action :check_owner_or_doctor
  include CustomFormsCommon

  def show
    @customForm = CustomForm.where(id: params[:id]).first
    @targetElementId = params[:target]
    @form_params = CustomForm.form_params
  end
end
