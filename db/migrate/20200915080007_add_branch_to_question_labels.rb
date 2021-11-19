class AddBranchToQuestionLabels < ActiveRecord::Migration[5.2]
  def change
    add_column :question_labels, :branch_to, :integer, default: 0
  end
end
