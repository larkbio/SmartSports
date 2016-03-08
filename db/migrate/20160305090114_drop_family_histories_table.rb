class DropFamilyHistoriesTable < ActiveRecord::Migration
  def up
    drop_table :family_histories
  end

  def down
    create_table :family_histories do |t|
      t.references :user
      t.string :source
      t.string :relative
      t.string :disease
      t.text :note

      t.timestamps
    end
  end
end
