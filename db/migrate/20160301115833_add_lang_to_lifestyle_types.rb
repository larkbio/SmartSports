class AddLangToLifestyleTypes < ActiveRecord::Migration
  def change
    add_column :lifestyle_types, :lang, :string
    add_column :genetics_types, :lang, :string
  end
end
