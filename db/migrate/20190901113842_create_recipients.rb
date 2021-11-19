class CreateRecipients < ActiveRecord::Migration[5.2]
  def change
    create_table :recipients do |t|
      t.references :account, foreign_key: true
      t.references :list, foreign_key: true
      t.string :email

      t.timestamps
    end
  end
end
