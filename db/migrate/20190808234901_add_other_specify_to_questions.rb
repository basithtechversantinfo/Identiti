class AddOtherSpecifyToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :other_specify, :integer
  end
end
