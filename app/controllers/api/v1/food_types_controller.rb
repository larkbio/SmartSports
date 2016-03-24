module Api::V1
  class FoodTypesController < ApiController
    respond_to :json
    include FoodTypesCommon
  end
end
