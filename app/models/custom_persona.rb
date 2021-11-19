class CustomPersona < ApplicationRecord
  belongs_to :survey
  belongs_to :group
  belongs_to :account
  has_and_belongs_to_many :submissions

  before_create :set_default_value

  def set_default_value
    public_token = Digest::SHA1.hexdigest([Time.now, rand(3453465)].join)
    self.public_token = public_token
  end
end