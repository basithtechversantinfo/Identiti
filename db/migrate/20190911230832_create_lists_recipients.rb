class CreateListsRecipients < ActiveRecord::Migration[5.2]
  def change
    create_table :lists_recipients do |t|
      t.integer :list_id
      t.integer :recipient_id

      t.timestamps
    end
  end
end
