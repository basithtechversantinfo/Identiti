class AddLastSeenAtToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :last_seen_at, :datetime
  end
end
