class CreateGenetics < ActiveRecord::Migration
  def change
    create_table :genetics do |t|
        t.references :user
        t.string :source
        t.string :relative
        t.string :diabetes
        t.string :antibody
        t.text :note
        t.string :group
        t.integer :diabetes_type_id
        t.integer :antibody_type_id
        t.integer :relative_type_id
        t.boolean :antibody_kind
        t.string :antibody_value

        t.timestamps
      end
      add_index :genetics, [:user_id]
      add_index :genetics, [:user_id, :source]
      add_index :genetics, [:user_id, :created_at]
  end
end
