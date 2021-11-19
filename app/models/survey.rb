class Survey < ApplicationRecord
  # default_scope {order(created_at: :desc)}

  attr_accessor :date_range
  attr_reader :date_range

  # FIXME add sender id to survey who activated survey also check for emails

  # FIXME use enum for survey_types
  # enum survey_type: {"Survey" => 0,
  #                        "" => 1,
  #                        "Persona" => 2}


  belongs_to :template_theme, optional: true
  belongs_to :group
  belongs_to :creator, class_name: 'Account', foreign_key: :created_by_id
  has_and_belongs_to_many :industries
  has_and_belongs_to_many :lists
  has_and_belongs_to_many :recipients
  has_many :categories, dependent: :destroy
  has_many :categories_surveys
  has_many :category_blocks, through: :categories_surveys, source: :category
  has_many :submissions, dependent: :destroy
  has_many :custom_personas, dependent: :destroy

  has_many :recipients_surveys
  has_many :allowed_recipients_surveys, -> { allowed_survey }, class_name: "RecipientsSurvey"

  accepts_nested_attributes_for :recipients_surveys, allow_destroy: true

  scope :undeleted_survey, -> { where("deleted_at IS NULL") }



  def recipients_surveys_for_form(survey_id, list_id, recipient_id)
    collection = recipients_surveys.where(list_id: list_id, recipient_id: recipient_id)
    collection.any? ? collection : recipients_surveys.build
  end

  enum survey_state: {"Draft" => 0,
                         "Active" => 1,
                         "Finished" => 2}

  enum persona_summary_display_types: {"Template 1" => 0, "Template 2" => 1}

  before_create :set_default_value
  after_save :set_delivery_time

  def set_default_value
    survey_token = Digest::SHA1.hexdigest([Time.now, rand].join)
    public_token = Digest::SHA1.hexdigest([Time.now, rand(34534656)].join)
    self.survey_token = survey_token
    self.public_token = public_token
    self.survey_state = 0
  end

  def aggregator
    SubmissionsAggregator.new(submissions: self.submissions,
                              areas: self.categories_surveys.pluck(:category_id))
  end

  def pdf_aggregator submission_ids
    SubmissionsAggregator.new(submissions: self.submissions.where(id: submission_ids),
                              areas: self.categories_surveys.pluck(:category_id))
  end

  def aggregator_scoring
    SubmissionsAggregatorScoring.new(submissions: self.submissions,
                              areas: self.categories_surveys.pluck(:category_id))
  end

  def pdf_aggregator_scoring submission_ids
    SubmissionsAggregatorScoring.new(submissions: self.submissions.where(id: submission_ids),
                              areas: self.categories_surveys.pluck(:category_id))
  end

  def customized_aggregator_scoring(submissions)
    CustomSubmissionsAggregatorScoring.new(submissions: submissions,
                              areas: self.categories_surveys.pluck(:category_id))
  end

  def summary_calculator
    SurveySummaryCalculator.new(submissions: self.submissions, recipients: self.recipients_surveys.where(allow_survey: "true").pluck(:recipient_id).uniq)
  end

  def set_delivery_time
    survey = self
    unless delivery_time.blank?
      # p self.delivery_time.strftime("%Y-%m-%d")+ ' ' + @record.date_time.to_datetime.strftime('%H:%M:%S')
      unless self.delivery_start_at.blank?
        delivery_period = self.delivery_start_at.localtime.strftime("%Y-%m-%d")+ ' ' + self.delivery_time.localtime.strftime('%H:%M:%S') 
        self.update_column(:delivery_time, delivery_period)
      end
 
    end
  end

  def self.all_step_valid_survey(survey)
    if !survey.title.present?
      false
    elsif !survey.welcome_page.present?
      false
    elsif (!survey.lists.present? || !survey.recipients_surveys.where(allow_survey: "true").present?) && (!survey.get_sharable_link)
      false
    elsif !survey.delivery_time.present?
      false
    elsif !survey.persona_summary_display_type.present?
      false
    else
      true
    end
  end

end
