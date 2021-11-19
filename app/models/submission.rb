class Submission < ApplicationRecord
  include QuestionOptionsHelper

  belongs_to :survey
  belongs_to :recipient, optional: true
  has_and_belongs_to_many :custom_personas
  has_many :submission_answers, dependent: :destroy

  after_save :generate_survey_persona
  after_save :migrate_data_to_submission_answers

  enum survey_eligibility: [:allowed, :notallowed]

  private
  def migrate_data_to_submission_answers
    begin

      submission = self
      submission_dat_json = submission.data_json
      submission_time_spent_dat_json = submission.submission_question_time_spent

      submission.survey.categories_surveys.each do |categories_survey|
        cat = categories_survey.category

        if submission_dat_json.present? and submission_dat_json['data'].present? and submission_dat_json['data'][cat.id.to_s].present?
          cat.questions.each do |q|
            if submission_dat_json['data'][cat.id.to_s][q.id.to_s].present?
              time_spent_on_question = if submission_time_spent_dat_json.present? and submission_time_spent_dat_json['data'].present? and submission_time_spent_dat_json['data'][cat.id.to_s].present? and submission_time_spent_dat_json['data'][cat.id.to_s][q.id.to_s].present?
                                         submission_time_spent_dat_json['data'][cat.id.to_s][q.id.to_s]
                                       end

              submission_dat_json_other = if submission_dat_json['other'].present? and submission_dat_json['other'][cat.id.to_s].present? and submission_dat_json['other'][cat.id.to_s][q.id.to_s].present?
                                            submission_dat_json['other'][cat.id.to_s][q.id.to_s]
                                          end

              SubmissionAnswer.find_or_create_by!(block_type: cat.display_type,
                                                  label: q.description,
                                                  answer: submission_dat_json['data'][cat.id.to_s][q.id.to_s],
                                                  score: get_drop_down_question_options_with_scored(q)[:options].present? ?
                                                             (get_drop_down_question_options_with_scored(q)[:options].map{|shape| (shape.is_a?(Array) ?
                                                                                                                                       [shape[0], shape[1]] :
                                                                                                                                       [shape, shape])}.to_h) : nil,

                                                  answer_other: submission_dat_json_other,

                                                  answers_target: submission_dat_json['data'][cat.id.to_s][q.id.to_s].is_a?(Hash) ? submission_dat_json['data'][cat.id.to_s][q.id.to_s]['country'] : submission_dat_json['data'][cat.id.to_s][q.id.to_s],
                                                  score_target: get_drop_down_question_options_with_scored(q)[:options].present? ?
                                                                    (get_drop_down_question_options_with_scored(q)[:options].map{|shape| (shape.is_a?(Array) ?
                                                                                                                                              [shape[0], shape[1]] :
                                                                                                                                              [shape, shape])}.to_h)[submission_dat_json['data'][cat.id.to_s][q.id.to_s]] : nil,

                                                  answers_target_additional: submission_dat_json['data'][cat.id.to_s][q.id.to_s].is_a?(Hash) ? JSON.parse(submission_dat_json['data'][cat.id.to_s][q.id.to_s].to_json) : nil,

                                                  time_spent: time_spent_on_question,
                                                  answer_data_type: SubmissionAnswer::ANSWER_DATA_TYPE_IDENTIFIERS[q.question_type],

                                                  question_title: q.description,
                                                  question_description: q.description,
                                                  question_type: q.question_type,
                                                  question_other_specify: q.other_specify,

                                                  category_title: cat.title,
                                                  category_description: cat.description,
                                                  category_display_type: cat.display_type,


                                                  submission_id: submission.id,
                                                  survey_id: submission.survey_id,
                                                  recipient_id: submission.recipient_id,
                                                  category_id: cat.id,
                                                  question_id: q.id)
            end
          end
        end

      end

    rescue => e
      logger.error e.message
      logger.error e.backtrace.join("\n")
    end
  end

  def generate_survey_persona
    begin
      GenerateSurveyPersonaJob.perform_later(self.survey_id)
    rescue => e
      logger.error e.message
      logger.error e.backtrace.join("\n")
    end
  end
end
