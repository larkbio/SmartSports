class AddFaq < ActiveRecord::Migration
  def change
    create_table :faqs do |t|
      t.integer :sortcode
      t.string :title
      t.text :detail
      t.string :lang
    end
  end
end
