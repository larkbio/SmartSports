module LifestyleTypesCommon
  def index
    lifestyle_types = LifestyleType.all
    limit = params[:limit]
    if limit
      lifestyle_types = lifestyle_types.limit(limit)
    end

    ret = lifestyle_types.map { |at|
      to_item(at)
    }

    render json: ret
  end

  def show
    id = params[:id]
    lt = LifestyleType.find_by_id(id)
    render json: to_item(lt)
  end

  private

  def to_item(lt)
    {
        name: lt.name,
        category: lt.category,
        hu: DB_HU_CONFIG['lifestyle'][lt['category']][lt['name']],
        en: DB_EN_CONFIG['lifestyle'][lt['category']][lt['name']]
    }
  end
end