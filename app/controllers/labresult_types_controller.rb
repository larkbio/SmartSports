class LabresultTypesController < ApplicationController
  respond_to :json

  def index
    id = params[:id]
    limit = params[:limit]
    if id
      labresult_types = LabresultType.where("id = '#{id}'")
    else
      labresult_types = LabresultType.all
    end
    if limit
      labresult_types = labresult_types.limit(limit)
    end

    labresult_types_en = labresult_types.clone
    labresult_types.map { |row_hu|
      row_hu['name'] =  DB_HU_CONFIG['labresult'][row_hu['category']][row_hu['name']]
      row_hu['lang'] =  'hu'
    }
    labresult_types_en.map { |row_en|
      row_en['name'] =  DB_EN_CONFIG['labresult'][row_en['category']][row_en['name']]
      row_en['lang'] =  'en'
      labresult_types.push(row_en)
    }

    render json: labresult_types
  end

end