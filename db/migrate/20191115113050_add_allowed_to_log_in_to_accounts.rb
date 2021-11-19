class AddAllowedToLogInToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :allowed_to_log_in, :boolean, default: true
  end
end
