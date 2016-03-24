class AddFoodTypeNameToDiets < ActiveRecord::Migration
  def change
    add_column :diets, :food_type_name, :string
  end
end
