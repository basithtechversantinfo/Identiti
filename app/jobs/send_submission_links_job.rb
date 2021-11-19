class SendSubmissionLinksJob < ApplicationJob
  queue_as :default

  def perform(survey)
    # Do something later
    if Survey.all_step_valid_survey(survey)
        recipients_surveys = survey.recipients_surveys.allowed_survey
        recipients_ids = recipients_surveys.pluck(:recipient_id).uniq
        unless recipients_ids.blank?
          survey.update_attribute(:sendmail_status, true)
          Recipient.find(recipients_ids).each do |recipient|
          	AccountMailer.send_submission_links("en", recipient, survey).deliver_later
          end
        end
      survey.update_column(:survey_sent_at, Time.now)
      puts "******************************Run at: #{Time.now}************************"
    end

  end
end
