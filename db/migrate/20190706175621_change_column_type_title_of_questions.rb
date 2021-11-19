class ChangeColumnTypeTitleOfQuestions < ActiveRecord::Migration[5.2]
  def change
    change_column :questions, :title, :text
  end
end
