class RecipientsSurvey < ApplicationRecord
  belongs_to :survey
  belongs_to :recipient
  belongs_to :list, optional: true

  scope :allowed_survey, -> { where(allow_survey: "true") }

end
