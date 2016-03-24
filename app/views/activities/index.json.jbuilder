json.array!(@activities) do |activity|
  json.extract! activity, :id, :user_id, :source, :activity, :intensity, :activity_type_id, :activity_type_name, :group, :game_id, :start_time, :end_time, :steps, :duration, :distance, :calories, :manual
  json.activity_name activity.activity_type.name if activity.activity_type
end
