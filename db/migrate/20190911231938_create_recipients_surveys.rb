class CreateRecipientsSurveys < ActiveRecord::Migration[5.2]
  def change
    create_table :recipients_surveys do |t|
      t.integer :survey_id
      t.integer :recipient_id

      t.timestamps
    end
  end
end
