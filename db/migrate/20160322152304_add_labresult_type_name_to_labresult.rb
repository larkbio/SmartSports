class AddLabresultTypeNameToLabresult < ActiveRecord::Migration
  def change
    add_column :labresults, :labresult_type_name, :string
  end
end
