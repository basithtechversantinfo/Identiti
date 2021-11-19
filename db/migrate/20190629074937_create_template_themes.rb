class CreateTemplateThemes < ActiveRecord::Migration[5.2]
  def change
    create_table :template_themes do |t|
      t.string :title
      t.timestamps
    end
  end
end
