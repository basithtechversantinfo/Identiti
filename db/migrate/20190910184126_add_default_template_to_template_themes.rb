class AddDefaultTemplateToTemplateThemes < ActiveRecord::Migration[5.2]
  def change
    add_column :template_themes, :default_template, :boolean, default: false
  end
end
