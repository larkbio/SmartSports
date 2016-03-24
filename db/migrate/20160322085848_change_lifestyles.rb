class ChangeLifestyles < ActiveRecord::Migration
  def change
    rename_column :lifestyles, :illness_type_id, :lifestyle_type_id
    add_column :lifestyles, :lifestyle_type_name, :string
  end
end
