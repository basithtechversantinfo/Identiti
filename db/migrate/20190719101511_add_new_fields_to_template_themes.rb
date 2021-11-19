class AddNewFieldsToTemplateThemes < ActiveRecord::Migration[5.2]
  def change
    add_column :template_themes, :thank_you_page, :text
    add_column :template_themes, :welcome_page, :text
  end
end
