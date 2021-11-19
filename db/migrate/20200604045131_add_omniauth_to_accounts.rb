class AddOmniauthToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :provider, :string
    add_index :accounts, :provider
    add_column :accounts, :uid, :string
    add_index :accounts, :uid
  end
end
