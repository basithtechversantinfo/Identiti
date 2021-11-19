class AccountMailer < ApplicationMailer
  include ApplicationHelper
  helper :application
  def invitation_to_collaborate(locale, sender, receiver, invitation_code, password)
    @sender = sender
    @receiver = receiver
    @password = password
    @invitation_code = invitation_code
    @locale = locale
    sender_email = (sender.company == true) ? sender.company_email : sender.sender_email
    sender_name = (sender.company == true) ? sender.company_name : sender.your_name
    mail(to: receiver.email, subject: "#{sender_name} Invitation to Collaborate", from: '"' + sender_name + '" <' + sender_email+ '>' )
  end

  def invitation_to_collaborate_update(locale, sender, receiver)
    @sender = sender
    @receiver = receiver
    @locale = locale
    sender_email = (sender.company == true) ? sender.company_email : sender.sender_email
    sender_name = (sender.company == true) ? sender.company_name : sender.your_name
    mail(to: receiver.email, subject: "#{sender_name} Collaboration Role Updated ", from: '"' + sender_name + '" <' + sender_email+ '>')
  end

  def send_submission_links(locale, receiver_email, survey)
    @receiver_email = receiver_email.email
    @encrypted_mail = receiver_email.encrypted_mail
    @survey = survey
    @locale = locale
    mail(to: receiver_email.email, subject: survey.email_subject, from:  '"' + survey.email_from + '" <' + survey.email_sender + '>' )
  end

  def new_client_alert(account)
    @account = account
    mail(to: "outbound@elasticpersonas.ai", subject: "New account notification")
  end

  def new_client_account_activate_alert(account)
    @account = account
    mail(to: account.email, subject: "Your Elastic Personas account has been approved", from: '"Elastic Personas" <outbound@elasticpersonas.ai>')
  end

  def new_client_account_created(account, password)
    @account = account
    @password = password
    mail(to: account.email, subject: "Your Elastic Personas account has been created", from: '"Elastic Personas" <outbound@elasticpersonas.ai>')
  end
end
