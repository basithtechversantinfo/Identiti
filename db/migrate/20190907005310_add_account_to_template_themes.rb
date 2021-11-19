class AddAccountToTemplateThemes < ActiveRecord::Migration[5.2]
  def change
    add_reference :template_themes, :account, foreign_key: true
  end
end
