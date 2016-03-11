class CreateInitVersion < ActiveRecord::Migration
  def change
    create_table :init_versions do |t|
      t.integer :version_number
    end
  end
end
