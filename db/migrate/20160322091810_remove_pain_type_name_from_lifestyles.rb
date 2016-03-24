class RemovePainTypeNameFromLifestyles < ActiveRecord::Migration
  def up
    remove_column :lifestyles, :pain_type_name
  end

  def down
    add_column :lifestyles, :pain_type_name, :string
  end
end
