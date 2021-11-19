json.extract! survey, :id, :title, :email_from, :email_sender, :email_subject, :delivery_end_at, :delivery_start_at, :delivery_time, :group_id, :created_at, :updated_at
json.url survey_url(survey, format: :json)
