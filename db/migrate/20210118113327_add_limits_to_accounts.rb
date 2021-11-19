class AddLimitsToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :survey_limit, :integer, default: 1
    add_column :accounts, :block_limit, :integer, default: 1
    add_column :accounts, :question_limit, :integer, default: 1
  end
end
