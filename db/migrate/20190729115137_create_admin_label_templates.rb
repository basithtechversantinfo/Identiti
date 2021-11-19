class CreateAdminLabelTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :label_templates do |t|
      t.string :title
      t.text :description
      t.integer :question_type
      t.references :account

      t.timestamps
    end
  end
end
