class AddShowTagToQuestionLabels < ActiveRecord::Migration[5.2]
  def change
    add_column :question_labels, :show_tag, :boolean, default: true
  end
end
