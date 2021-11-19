class AddCharLengthToQuestionLabels < ActiveRecord::Migration[5.2]
  def change
    add_column :question_labels, :max_length, :integer
    add_column :question_labels, :min_length, :integer
  end
end
