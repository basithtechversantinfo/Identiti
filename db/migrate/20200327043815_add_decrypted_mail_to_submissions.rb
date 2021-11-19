class AddDecryptedMailToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :decrypted_mail, :string
  end
end
