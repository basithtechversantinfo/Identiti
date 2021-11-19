class ListsRecipient < ApplicationRecord
  belongs_to :list
  belongs_to :recipient
end
