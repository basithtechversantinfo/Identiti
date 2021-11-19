class AddRecreatedAtToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :recreated_at, :datetime
  end
end
