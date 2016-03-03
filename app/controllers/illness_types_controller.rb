class IllnessTypesController < ApplicationController
  respond_to :json

  def index
    id = params[:id]
    limit = params[:limit]
    if id
      illness_types = IllnessType.where("id = '#{id}'")
    else
      illness_types = IllnessType.all
    end
    if limit
      illness_types = illness_types.limit(limit)
    end

    pain_types = LifestyleType.where("category = 'pain'")

    pain_types_en = pain_types.clone
    pain_types.map { |row_hu|
      row_hu['name'] =  DB_HU_CONFIG['lifestyle']['pains'][row_hu['name']]
      row_hu['lang'] =  'hu'
    }

    pain_types_en.map { |row_en|
      row_en['name'] =  DB_EN_CONFIG['lifestyle']['pains'][row_en['name']]
      row_en['lang'] =  'en'
      pain_types.push(row_en)
    }

    render json: [illness_types,pain_types]
  end

end