class AddScoreToQuestionLabels < ActiveRecord::Migration[5.2]
  def change
    add_column :question_labels, :score, :string
  end
end
