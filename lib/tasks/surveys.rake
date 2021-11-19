namespace :surveys do
  desc "Sent surveys link to all recipients with delivery time"
  task sent_survey: :environment do
  	surveys = Survey.where.not(survey_state: 0).where("delivery_time BETWEEN ? AND ?", Time.now-15.minutes, Time.now)

    unless surveys.blank?
  	  surveys.each do |survey|
  	  	p survey.survey_sent_at.nil?
  	  	if survey.survey_sent_at.nil? && survey.sendmail_status == false
	  	  	puts "***************************Survey ID:#{survey.id}**************************"
          SendSubmissionLinksJob.perform_later(survey)
	      end
  	  end
    	
    end
  	p surveys.count 
  end

end
