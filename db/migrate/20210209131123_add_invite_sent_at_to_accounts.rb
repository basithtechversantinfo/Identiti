class AddInviteSentAtToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :invite_sent_at, :datetime
  end
end
