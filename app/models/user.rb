class User < Account
  default_scope {order(created_at: :desc)}
  # default_scope { where(account_type: 'user')}

  belongs_to :account
  enum role: [:admin, :creator, :analyzer]
  enum active: [:pending, :active]
  validates_presence_of :email, :role, :your_name
  validates_uniqueness_of :email, message: 'This email is already linked to another account'

  has_one_attached :image
  attr_accessor :multi_emails
  attr_accessor :okta_login
  
end
