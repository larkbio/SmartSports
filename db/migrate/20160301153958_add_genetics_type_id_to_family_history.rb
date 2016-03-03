class AddGeneticsTypeIdToFamilyHistory < ActiveRecord::Migration
  def change
    add_column :family_histories, :genetics_type_id, :integer
  end
end
