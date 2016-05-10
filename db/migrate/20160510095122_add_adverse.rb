class AddAdverse < ActiveRecord::Migration
  def change
    create_table :adverses do |t|
      t.references :user, index: true
      t.string :effect_present
      t.text :effect_detail
      t.datetime :time
    end
  end
end
