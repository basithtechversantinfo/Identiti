class ChangeDefaultToQuestionLabels < ActiveRecord::Migration[5.2]
  def change
  	change_column_default :question_labels, :position, from: 50, to: 0
  end
end
