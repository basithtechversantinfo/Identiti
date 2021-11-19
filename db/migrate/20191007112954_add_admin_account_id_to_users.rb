class AddAdminAccountIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :admin_account_id, :integer
  end
end
