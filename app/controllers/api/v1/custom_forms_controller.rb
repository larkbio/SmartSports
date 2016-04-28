module Api::V1
  class CustomFormsController < ApiController
    before_action :check_owner_or_doctor

    include CustomFormsCommon
  end

end
