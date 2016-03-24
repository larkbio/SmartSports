module Api::V1
  class GeneticsTypesController < ApiController
    respond_to :json
    include GeneticsTypesCommon
  end
end
