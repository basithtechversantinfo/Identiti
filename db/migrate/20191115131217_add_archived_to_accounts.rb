class AddArchivedToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :archived, :boolean, default: false
  end
end
