json.array!(@diets) do |diet|
  json.extract! diet, :id, :user_id, :source, :amount, :date, :calories, :carbs, :fat, :prot, :created_at, :updated_at, :favourite
  json.name diet.food_type.name if diet.food_type
  json.category diet.food_type.category if diet.food_type
end
