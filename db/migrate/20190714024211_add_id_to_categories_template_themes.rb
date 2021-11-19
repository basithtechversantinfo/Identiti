class AddIdToCategoriesTemplateThemes < ActiveRecord::Migration[5.2]
  def change
    add_column :categories_template_themes, :id, :primary_key
  end
end
