class Group < ApplicationRecord
  default_scope {order(created_at: :desc)}

  belongs_to :account
  has_many :surveys, dependent: :destroy
  has_many :custom_personas, dependent: :destroy

  validates_presence_of :title

  has_one_attached :image
end
