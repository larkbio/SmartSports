json.array!(@medications) do |medication|
  json.extract! medication, :id, :user_id, :date,:source, :amount, :created_at, :updated_at, :medication_type_id, :medication_type_name, :favourite
end

