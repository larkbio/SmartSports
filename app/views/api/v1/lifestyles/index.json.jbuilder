json.array!(@lifestyles) do |lifestyle|
  json.extract! lifestyle, :id, :user_id, :lifestyle_type_id, :lifestyle_type_name, :source, :group, :name, :details, :amount, :period_volume, :data
  json.name lifestyle_type.name if lifestyle.lifestyle_type
  json.category lifestyle_type.category if lifestyle.lifestyle_type
end
