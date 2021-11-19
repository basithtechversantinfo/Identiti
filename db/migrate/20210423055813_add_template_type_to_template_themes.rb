class AddTemplateTypeToTemplateThemes < ActiveRecord::Migration[5.2]
  def change
  	add_column :template_themes, :template_type, :integer, default: 0
  end
end
