class AddTagToQuestionLabels < ActiveRecord::Migration[5.2]
  def change
    add_column :question_labels, :tag, :string
  end
end
