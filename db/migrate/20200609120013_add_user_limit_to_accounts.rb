class AddUserLimitToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :user_limit, :integer, default: 1
  end
end
