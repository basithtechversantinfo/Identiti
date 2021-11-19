class AddLoginOptionsToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :login_options, :integer, default: 0
  end
end
