class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable :confirmable,
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :lockable, :trackable, :omniauthable, omniauth_providers: [:oktaoauth]

  validates_presence_of :your_name
  validates_presence_of :company_name, :company_email, if: lambda { |o| o.company == true }
  validates_presence_of :sender_email, if: lambda { |o| o.company == false }

  has_many :users, dependent: :destroy
  has_many :admin_users, class_name: "User", foreign_key: "account_id"

  has_many :template_themes, dependent: :destroy

  has_many :categories, dependent: :destroy

  has_many :groups, dependent: :destroy

  has_many :lists, dependent: :destroy
  has_many :recipients, dependent: :destroy


  has_one :account_setting
  has_and_belongs_to_many :email_notification_types

  has_one_attached :image
  has_one_attached :company_image

  enum login_options: [ :normal, :okta ]

  def active_for_authentication?
    super and if self.account_type == 'client'
                self.allowed_to_log_in?
              elsif account_type == 'user'
                self.allowed_to_log_in? and self.active == 1 and self.archived == false
              end
  end

  def self.from_omniauth(auth)
    account = Account.find_by(email: auth["info"]["email"])
    if account.blank?
      account = Account.new
      account.provider = auth['provider']
      account.uid = auth['uid']
      account.email = auth['info']['email']
      account.your_name = auth['info']['name']
      account.company = false
      account.sender_email = auth['info']['email']
      account.save(validate: false)
    else
      account.provider = auth['provider']
      account.uid = auth['uid']
      account.save(validate: false)
    end
    account
  end

  def send_devise_notification(notification, *args)
    unless(notification == :password_change && sign_in_count.zero? && invitation_code.present?)
      super
    end
  end
end
