json.array!(@adverses) do |adverse|
  json.extract! adverse, :id, :user_id, :effect_present, :effect_detail, :time
end
