class AddCreatedByIdToRecipients < ActiveRecord::Migration[5.2]
  def change
    add_column :recipients, :created_by_id, :integer
  end
end
