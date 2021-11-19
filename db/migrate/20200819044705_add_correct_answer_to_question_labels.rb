class AddCorrectAnswerToQuestionLabels < ActiveRecord::Migration[5.2]
  def change
    add_column :question_labels, :correct_answer, :boolean, default: true
  end
end
