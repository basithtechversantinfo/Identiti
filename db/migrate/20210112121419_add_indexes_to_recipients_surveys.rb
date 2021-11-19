class AddIndexesToRecipientsSurveys < ActiveRecord::Migration[5.2]
  def change
  	add_index :recipients_surveys, :recipient_id 
  	add_index :recipients_surveys, :survey_id
  	add_index :recipients_surveys, :list_id
  	add_index :recipients_surveys, :allow_survey
  end
end
