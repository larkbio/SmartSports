module Api::V1
  class ActivityTypesController < ApiController
    respond_to :json
    include ActivityTypesCommon
  end
end
