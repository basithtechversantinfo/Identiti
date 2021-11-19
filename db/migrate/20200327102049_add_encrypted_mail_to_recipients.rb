class AddEncryptedMailToRecipients < ActiveRecord::Migration[5.2]
  def change
    add_column :recipients, :encrypted_mail, :string
  end
end
