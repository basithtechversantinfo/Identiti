class AddIsBranchingToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :is_branching, :boolean, default: false
  end
end
