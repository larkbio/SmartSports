json.array!(@genetics) do |genetics|
  json.extract! genetics, :id, :user_id, :source, :source, :relative, :diabetes, :antibody, :note, :group, :relative_type_id, :relative_type_name, :diabetes_type_id, :diabetes_type_name, :antibody_type_id, :antibody_type_name, :antibody_kind, :antibody_value, :created_at, :updated_at
  json.name genetics_type.name if genetics.genetics_type
  json.category genetics_type.category if genetics.genetics_type
end

