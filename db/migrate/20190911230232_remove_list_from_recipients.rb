class RemoveListFromRecipients < ActiveRecord::Migration[5.2]
  def change
    remove_reference :recipients, :list, foreign_key: true
  end
end
