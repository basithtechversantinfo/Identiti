class AddAccountToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_reference :questions, :account, foreign_key: true
  end
end
