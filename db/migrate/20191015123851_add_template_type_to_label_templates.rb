class AddTemplateTypeToLabelTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :label_templates, :template_type, :integer, default: 0
  end
end
