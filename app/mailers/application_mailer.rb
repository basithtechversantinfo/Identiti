class ApplicationMailer < ActionMailer::Base
  default from: '"Elastic Personas" <outbound@elasticpersonas.ai>'
  layout 'mailer'
end
