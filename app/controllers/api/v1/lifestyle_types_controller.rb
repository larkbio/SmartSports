module Api::V1
  class LifestyleTypesController < ApiController
    respond_to :json
    include LifestyleTypesCommon
  end
end
