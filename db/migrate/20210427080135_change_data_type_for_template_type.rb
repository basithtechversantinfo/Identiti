class ChangeDataTypeForTemplateType < ActiveRecord::Migration[5.2]
  def change
  	change_column :template_themes, :template_type, :string, default: nil
  end
end
