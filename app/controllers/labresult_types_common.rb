module LabresultTypesCommon
  def index
    labresult_types = LabresultType.all
    limit = params[:limit]
    if limit
      labresult_types = labresult_types.limit(limit)
    end

    ret = labresult_types.map { |at|
      to_item(at)
    }

    render json: ret
  end

  def show
    id = params[:id]
    lt = LabresultType.find_by_id(id)
    render json: to_item(lt)
  end

  private

  def to_item(lt)
    {
        name: lt.name,
        category: lt.category,
        hu: DB_HU_CONFIG['labresult'][lt['category']][lt['name']],
        en: DB_EN_CONFIG['labresult'][lt['category']][lt['name']]
    }
  end
end