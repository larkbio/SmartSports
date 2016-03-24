module GeneticsTypesCommon
  def index
    genetics_types = GeneticsType.all
    limit = params[:limit]
    if limit
      genetics_types = genetics_types.limit(limit)
    end

    ret = genetics_types.map { |at|
      to_item(at)
    }

    render json: ret
  end

  def show
    id = params[:id]
    gt = GeneticsType.find_by_id(id)
    render json: to_item(gt)
  end

  private

  def to_item(gt)
    {
        name: gt.name,
        category: gt.category,
        hu: DB_HU_CONFIG['genetics'][gt['category']][gt['name']],
        en: DB_EN_CONFIG['genetics'][gt['category']][gt['name']]
    }
  end
end