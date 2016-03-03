class FoodTypesController < ApplicationController
  respond_to :json

  def index
    id = params[:id]
    ftype = params[:type]
    limit = params[:limit]
    if id
      food_types = FoodType.where("id = '#{id}'")
    else
      food_types = FoodType.all
      if ftype == 'drink'
        food_types = food_types.where("category = 'Drink'")
      elsif ftype=='food'
        food_types = food_types.where("category = 'Food'")
      end
    end
    if limit
      food_types = food_types.limit(limit)
    end

    food_types_en = food_types.clone

    food_types.map { |row_hu|
      row_hu['name'] =  DB_HU_CONFIG['diets'][row_hu['category']][row_hu['name']]
      row_hu['lang'] =  'hu'
    }

    food_types_en.map { |row_en|
      row_en['name'] =  DB_EN_CONFIG['diets'][row_en['category']][row_en['name']]
      row_en['lang'] =  'en'
      food_types.push(row_en)
    }

    render json: food_types
  end

end