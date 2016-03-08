class AddLangToIllnessTypes < ActiveRecord::Migration
  def change
    add_column :illness_types, :lang, :string
  end
end
