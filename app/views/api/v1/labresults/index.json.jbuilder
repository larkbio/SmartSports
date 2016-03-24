json.array!(@labresults) do |labresult|
  json.extract! labresult, :id, :user_id, :source, :category, :hba1c, :ldl_chol, :egfr_epi, :ketone, :date, :created_at, :updated_at, :labresult_type_id, :labresult_type_name
  json.name labresult_type.name if labresult.labresult_type
  json.category labresult_type.category if labresult.labresult_type
end