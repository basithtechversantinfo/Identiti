class List < ApplicationRecord
  default_scope {order(created_at: :desc)}

  attr_accessor :multi_emails
  attr_reader :multi_emails

  belongs_to :account
  has_and_belongs_to_many :recipients
  has_and_belongs_to_many :surveys

  scope :not_deleted, -> {where(archived: false)}
end
