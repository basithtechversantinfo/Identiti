class AccountSetting < ApplicationRecord
  belongs_to :account
  belongs_to :industry
  serialize :billings_emails, JSON
  EMPLOYEE_COUNT = ["1 to 50", "51 to 100", "101 to 200", ">200"]
end
