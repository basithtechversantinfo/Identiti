class AddLabelTemplateIdToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :label_template_id, :integer, default: 0
  end
end
