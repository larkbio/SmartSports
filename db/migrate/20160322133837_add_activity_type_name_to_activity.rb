class AddActivityTypeNameToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :activity_type_name, :string
  end
end
