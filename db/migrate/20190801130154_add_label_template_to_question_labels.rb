class AddLabelTemplateToQuestionLabels < ActiveRecord::Migration[5.2]
  def change
    add_reference :question_labels, :label_template, foreign_key: true
  end
end
