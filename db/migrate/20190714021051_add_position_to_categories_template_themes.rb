class AddPositionToCategoriesTemplateThemes < ActiveRecord::Migration[5.2]
  def change
    add_column :categories_template_themes, :position, :integer, default: 0
  end
end
