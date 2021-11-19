class CreateIndustriesTemplateThemes < ActiveRecord::Migration[5.2]
  def change
    create_table :industries_template_themes do |t|
      t.integer :industry_id
      t.integer :template_theme_id

      t.timestamps
    end
  end
end
