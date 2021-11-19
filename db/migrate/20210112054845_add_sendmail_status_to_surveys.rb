class AddSendmailStatusToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :sendmail_status, :boolean, default: false
  end
end
