class AddNewAccountToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :new_account, :boolean, default: true
  end
end
