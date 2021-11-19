class AddRequireNewPasswordToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :require_new_password, :boolean, default: false
  end
end
