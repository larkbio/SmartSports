module Api::V1
  class MedicationTypesController < ApiController
    respond_to :json
    include MedicationTypesCommon
  end
end
