class Recipient < ApplicationRecord
  default_scope {order(created_at: :desc)}

  belongs_to :account
  has_and_belongs_to_many :lists
  has_and_belongs_to_many :surveys
  has_many :submissions, dependent: :destroy

  attr_accessor :single_email, :multi_emails
  attr_reader :single_email, :multi_emails

  before_create :set_default_value
  before_save :set_encrypted_mail

  def set_default_value
    faker_full_name = Faker::Name.unique.name
    faker_gender = Faker::Gender.binary_type
    self.full_name = faker_full_name
    self.gender = faker_gender
    self.image_slug = "gender/#{faker_gender.downcase}-#{rand(1..99)}.png"
  end

  def set_encrypted_mail
    key = ENV['ENCRYPT_KEY'].bytes[0..31].pack( "c" * 32 )
    crypt = ActiveSupport::MessageEncryptor.new(key)
    encrypted_data = crypt.encrypt_and_sign(self.email)
    self.encrypted_mail = encrypted_data
  end

end
