class GeneticsTypesController < ApplicationController
  respond_to :json

  def index
    id = params[:id]
    limit = params[:limit]
    if id
      genetics_types = GeneticsType.where("id = '#{id}'")
    else
      genetics_types = GeneticsType.all
    end
    if limit
      genetics_types = genetics_types.limit(limit)
    end

    genetics_types_en = genetics_types.clone
    genetics_types.map { |row_hu|
      row_hu['name'] =  DB_HU_CONFIG['genetics'][row_hu['category']][row_hu['name']]
      row_hu['lang'] =  'hu'
    }
    genetics_types_en.map { |row_en|
      row_en['name'] =  DB_EN_CONFIG['genetics'][row_en['category']][row_en['name']]
      row_en['lang'] =  'en'
      genetics_types.push(row_en)
    }

    render json: genetics_types
  end

end