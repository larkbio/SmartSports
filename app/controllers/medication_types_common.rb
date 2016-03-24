module MedicationTypesCommon
  def index
    medication_types = MedicationType.all
    limit = params[:limit]
    if limit
      medication_types = medication_types.limit(limit)
    end

    ret = medication_types.map { |mt|
      if mt.group == "oral" || mt.group == "insulin"
        to_item_hu(mt)
      else
        to_item_en(mt)
      end
    }

    render json: ret
  end

  def show
    id = params[:id]
    mt = MedicationType.find_by_id(id)
    if mt.group == "oral" || mt.group == "insulin"
      ret = to_item_hu(mt)
    else
      ret = to_item_en(mt)
    end
    render json: ret
  end

  private

  def to_item_hu(mt)
    {
        name: mt.id,
        category: mt.group,
        hu: mt.name,
        en: ""
    }
  end

  def to_item_en(mt)
    {
        name: mt.id,
        category: mt.group,
        hu: "",
        en: mt.name
    }
  end
end