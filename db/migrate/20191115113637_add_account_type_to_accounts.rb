class AddAccountTypeToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :account_type, :string, default: 'client'
  end
end
