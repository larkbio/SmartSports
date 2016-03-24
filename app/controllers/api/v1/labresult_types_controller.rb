module Api::V1
  class LabresultTypesController < ApiController
    respond_to :json
    include LabresultTypesCommon
  end
end
