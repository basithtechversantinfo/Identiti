class AddCharLengthToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :other_label_max_length, :integer
    add_column :questions, :other_label_min_length, :integer
  end
end
