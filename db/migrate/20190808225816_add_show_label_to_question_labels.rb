class AddShowLabelToQuestionLabels < ActiveRecord::Migration[5.2]
  def change
    add_column :question_labels, :show_label, :boolean, default: true
  end
end
