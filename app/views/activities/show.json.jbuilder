json.extract! @activity, :id, :user_id, :source, :activity, :group, :game_id, :start_time, :end_time, :steps, :duration, :distance, :calories, :manual, :intensity, :created_at, :updated_at, :favourite, :activity_type_id, :activity_type_name
json.activity_name @activity.activity_type.name if @activity.activity_type
json.activity_category @activity.activity_type.category if @activity.activity_type
json.activity_lang @activity.activity_type.lang if @activity.activity_type