class ChangeProfile < ActiveRecord::Migration
  def up
    remove_column :profiles, :dateofbirth
    add_column :profiles, :year_of_birth, :integer
  end
  def down
    add_column :profiles, :dateofbirth, :datetime
    remove_column :profiles, :year_of_birth
  end
end
