class CreateJoinTableAccountsEmailNotificationTypes < ActiveRecord::Migration[5.2]
  def change
    create_join_table :accounts, :email_notification_types do |t|
      # t.index [:account_id, :email_notification_type_id]
      # t.index [:email_notification_type_id, :account_id]
    end
  end
end
