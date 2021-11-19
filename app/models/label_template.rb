class LabelTemplate < ApplicationRecord
  enum question_type: {"Multiple Choices (Single Select)" => 0,
                       "Multiple Choices (Multi Select)" => 4,
                       "Drop-down Selector (Single Select)" => 1,
                       "Drop-down Selector (Multi Select)" => 2,
                       "Rating Scale" => 3,
                       "Scores" => 7,
                       # "Rating Scale (with custom score)" => 33,
                       # "Comment Box" => 5,
                       # "Number Field" => 6,
                       # "Star Ratings" => 12,
                       # "Range Slider" => 77,
                       # "Geographic Location" => 8,
                       # "Country with States(Drop-down Selector)" => 9,
                       # "Country-States-City(Drop-down Selector)" => 10,
                       # "Address Fields" => 10,
                       # "Date Range" => 12,
                       # "Date" => 11
  }

  enum other_specify: {
      "No" => 1,
      "Yes" => 0
  }

  enum template_type: {
      "Public" => 0,
      "Private" => 1
  }

  enum geographic_type: {"Country" => 0,
                         "Country-States" => 1,
                         "Country-States-Cities" => 2}

  scope :user_default_type, -> { where(default_type: 'user-custom') }
  scope :system_default_type, -> { where(default_type: 'system-custom') }

  belongs_to :account, optional: true
  has_many :question_labels, dependent: :destroy
  accepts_nested_attributes_for :question_labels, reject_if: :all_blank, allow_destroy: true

  validates_presence_of :title, :question_type, :question_labels
end
