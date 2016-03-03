class ActivityTypesController < ApplicationController
  respond_to :json

  def index
    id = params[:id]
    category = params[:category]
    limit = params[:limit]
    if id
      activity_types = ActivityType.where("id = '#{id}'")
    else
      activity_types = ActivityType.all
      if category == 'sport'
        activity_types = activity_types.where("category = 'sport'")
      elsif category == 'other'
        activity_types = activity_types.where("category != 'sport'")
      end
    end
    if limit
      activity_types = activity_types.limit(limit)
    end

    activity_types_en = activity_types.clone

    activity_types.map { |row_hu|
      row_hu['name'] =  DB_HU_CONFIG['activities'][row_hu['name']]
      row_hu['lang'] =  'hu'
    }

    activity_types_en.map { |row_en|
      row_en['name'] =  DB_EN_CONFIG['activities'][row_en['name']]
      row_en['lang'] =  'en'
      activity_types.push(row_en)
    }

    render json: activity_types
  end

end