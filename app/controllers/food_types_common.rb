module FoodTypesCommon
  def index
    food_types = FoodType.all
    limit = params[:limit]
    if limit
      food_types = food_types.limit(limit)
    end

    ret = food_types.map { |ft|
      to_item(ft)
    }

    render json: ret
  end

  def show
    id = params[:id]
    ft = FoodType.find_by_id(id)
    render json: to_item(ft)
  end

  private

  def to_item(ft)
    {
        name: ft.name,
        category: ft.category,
        hu: DB_HU_CONFIG['diets'][ft['category']][ft['name']],
        en: DB_EN_CONFIG['diets'][ft['category']][ft['name']]
    }
  end
end