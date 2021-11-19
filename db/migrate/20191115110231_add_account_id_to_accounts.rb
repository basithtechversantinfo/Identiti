class AddAccountIdToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :account_id, :bigint
    add_column :accounts, :role, :integer
    add_column :accounts, :active, :integer, default: 0
    add_column :accounts, :invitation_code, :string
  end
end
