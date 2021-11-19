class CreateJoinTableCategoriesTemplateThemes < ActiveRecord::Migration[5.2]
  def change
    create_join_table  :template_themes, :categories do |t|
      # t.index [:admin_category_id, :template_theme_id]
      # t.index [:template_theme_id, :admin_category_id]
    end
  end
end
