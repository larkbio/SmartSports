class AddLabresultTypeIdToLabresult < ActiveRecord::Migration
  def change
    add_column :labresults, :labresult_type_id, :integer
  end
end
