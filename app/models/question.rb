class Question < ApplicationRecord
  enum question_type: {"Multiple Choices (Single Select)" => 0,
                       "Multiple Choices (Multi Select)" => 4,
                       "Drop-down Selector (Single Select)" => 1,
                       "Drop-down Selector (Multi Select)" => 2,
                       "Rating Scale" => 3,
                       # "Rating Scale (with custom score)" => 33,
                       "Comment Box" => 5,
                       "Number Field" => 6,
                       "Star Ratings" => 12,
                       "Scores" => 7,
                       "Range Slider" => 77,
                       "Geographic Location" => 8,
                       # "Country with States(Drop-down Selector)" => 9,
                       # "Country-States-City(Drop-down Selector)" => 10,
                       # "Address Fields" => 10,
                       # "Date Range" => 12,
                       "Date" => 11,
                       "Visual Choices" => 13,
                       "Screener" => 14
                     }


  enum chart_type: {"Bar Chart (Vertical)" => 0,
                    "Bar Chart (Horizontal)" => 4,
                    # "Radar Chart" => 1,
                    "Pie Chart" => 2,
                    "Polar Area" => 3,
                    "NPS Chart" => 5,
                    "Wordcloud Chart" => 6}

  enum other_specify: {
      "No" => 1,
      "Yes" => 0,
  }

  enum geographic_type: {"Country" => 0,
                         "Country-States" => 1,
                         "Country-States-Cities" => 2}



  def self.ranges_array
    (0..10).to_a
  end

  include RailsSortable::Model
  set_sortable :position

  default_scope { order(position: :asc) }

  belongs_to :label_template, optional: true
  belongs_to :category
  has_many :question_labels, dependent: :destroy
  accepts_nested_attributes_for :question_labels, reject_if: :all_blank, allow_destroy: true
  def check_question_type_for_sort locked, params
    if locked
      return self.question_type == Question.question_types.key(1) || self.question_type == Question.question_types.key(0) || self.question_type == Question.question_types.key(3) || self.question_type == Question.question_types.key(4) || self.question_type == Question.question_types.key(13) || self.question_type == Question.question_types.key(2) || self.question_type == Question.question_types.key(7)
    else
      return params[:question][:question_type] == Question.question_types.key(1) || params[:question][:question_type] == Question.question_types.key(0) || params[:question][:question_type] == Question.question_types.key(3) || params[:question][:question_type] == Question.question_types.key(4) || params[:question][:question_type] == Question.question_types.key(13) || params[:question][:question_type] == Question.question_types.key(2) || params[:question][:question_type] == Question.question_types.key(7)
    end
  end
end
