json.array!(@lifestyles) do |lifestyle|
  json.extract! lifestyle, :id, :user_id, :lifestyle_type_id, :lifestyle_type_name, :source, :group, :name, :details, :amount, :period_volume, :data
  json.url lifestyle_url(lifestyle, format: :json)
end
