class AddSortResultsToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :sort_results, :boolean, default: false
  end
end
