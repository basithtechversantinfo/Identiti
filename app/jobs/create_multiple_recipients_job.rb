class CreateMultipleRecipientsJob < ApplicationJob
  queue_as :default

  def perform(multi_emails, list_id, current_account_id, community_account)
    # Do something later
    multi_emails.split(",").each do |recipient|
	    recipient = Recipient.find_or_create_by(account_id: community_account.id, email: recipient.strip, created_by_id: current_account_id)
	    ListsRecipient.find_or_create_by(recipient_id: recipient.id, list_id: list_id)
    end
  end
end
