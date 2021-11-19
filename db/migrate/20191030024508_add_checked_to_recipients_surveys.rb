class AddCheckedToRecipientsSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :recipients_surveys, :allow_survey, :string
  end
end
