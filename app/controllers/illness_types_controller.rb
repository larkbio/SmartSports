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

    illness_types_en = illness_types.clone

    illness_types.map { |row_hu|
      row_hu['name'] =  DB_HU_CONFIG['lifestyle']['illnesses'][row_hu['name']]
      row_hu['lang'] =  'hu'
    }

    illness_types_en.map { |row_en|
      row_en['name'] =  DB_EN_CONFIG['lifestyle']['illnesses'][row_en['name']]
      row_en['lang'] =  'en'
      illness_types.push(row_en)
    }

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