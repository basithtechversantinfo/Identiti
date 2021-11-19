class AddTrialToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :trial, :boolean, default: false
    add_column :accounts, :trial_password, :text
  end
end
