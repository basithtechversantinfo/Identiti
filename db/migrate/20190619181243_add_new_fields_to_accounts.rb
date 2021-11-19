class AddNewFieldsToAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :accounts, :company, :boolean, default: true
    add_column :accounts, :company_name, :string
    add_column :accounts, :company_email, :string
    add_column :accounts, :sender_email, :string
  end
end
