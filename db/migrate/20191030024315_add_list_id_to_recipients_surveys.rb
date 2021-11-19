class AddListIdToRecipientsSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :recipients_surveys, :list_id, :integer
  end
end
