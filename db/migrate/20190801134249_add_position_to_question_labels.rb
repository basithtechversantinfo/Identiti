class AddPositionToQuestionLabels < ActiveRecord::Migration[5.2]
  def change
    add_column :question_labels, :position, :integer, default: 50
  end
end
