class AddBillingEmailsToAccountSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :account_settings, :billing_emails, :json
  end
end
