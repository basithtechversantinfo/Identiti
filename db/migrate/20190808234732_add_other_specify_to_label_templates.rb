class AddOtherSpecifyToLabelTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :label_templates, :other_specify, :integer
  end
end
