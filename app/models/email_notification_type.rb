class EmailNotificationType < ApplicationRecord
  has_and_belongs_to_many :email_notification_types
end
