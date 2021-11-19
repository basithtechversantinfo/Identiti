class CreateCustomPersonas < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_personas do |t|
      t.string :title
      t.string :persona_name
      t.references :survey, foreign_key: true
      t.references :group, foreign_key: true
      t.integer :created_by_id
      t.references :account, foreign_key: true

      t.timestamps
    end

    add_column :custom_personas, :data_json, :jsonb
    add_index :custom_personas, :data_json, using: :gin
  end
end
