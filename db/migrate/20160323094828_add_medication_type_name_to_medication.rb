class AddMedicationTypeNameToMedication < ActiveRecord::Migration
  def change
    add_column :medications, :medication_type_name, :string
  end
end
