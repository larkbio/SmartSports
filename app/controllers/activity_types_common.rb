module ActivityTypesCommon
  def index
    activity_types = ActivityType.all
    limit = params[:limit]
    if limit
      activity_types = activity_types.limit(limit)
    end

    ret = activity_types.map { |at|
      to_item(at)
    }

    render json: ret
  end

  def show
    id = params[:id]
    at = ActivityType.find_by_id(id)
    render json: to_item(at)
  end

  private

  def to_item(at)
    {
        name: at.name,
        category: at.category,
        hu: DB_HU_CONFIG['activities'][at['name']],
        en: DB_EN_CONFIG['activities'][at['name']]
    }
  end
end