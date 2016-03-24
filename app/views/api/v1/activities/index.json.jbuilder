json.array!(@activities) do |activity|
  json.extract! activity, :id, :user_id, :source, :activity, :intensity, :activity_type_id, :activity_type_name, :group, :game_id, :start_time, :end_time, :steps, :duration, :distance, :calories, :manual
  json.name activity_type.name if activity.activity_type
  json.category activity_type.category if activity.activity_type
end
