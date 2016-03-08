class CreateLabresultType < ActiveRecord::Migration
  def change
    create_table :labresult_types do |t|
      t.string :name
      t.string :category
      t.string :lang
    end
  end
end
