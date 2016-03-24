class AddRelativeTypeNameToGenetics < ActiveRecord::Migration
  def change
    add_column :genetics, :relative_type_name, :string
    add_column :genetics, :diabetes_type_name, :string
    add_column :genetics, :antibody_type_name, :string
  end
end
