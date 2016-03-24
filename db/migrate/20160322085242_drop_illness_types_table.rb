class DropIllnessTypesTable < ActiveRecord::Migration
  def up
    drop_table :illness_types
  end

  def down
    create_table :illness_types do |t|
      t.string :name
      t.string :lang
    end
  end
end
