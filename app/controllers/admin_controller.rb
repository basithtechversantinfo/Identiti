class AdminController < ApplicationController

  def dashboard
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @accounts = Account.all
   
    @client_count = @accounts.where(account_type: 'client', admin: false).count

    @users_count = @accounts.where(account_type: 'user', archived: false).count
    
    @surveys = Survey.all

    @surveys_count = @surveys.count

    @active_surveys_count = @surveys.select {|survey| survey if active_survey_groups(survey)}.count

    @draft_surveys_count = @surveys.select {|survey| survey if draft_survey_groups(survey)}.count

    @finished_surveys_count = @surveys.select {|survey| survey if finished_survey_groups(survey)}.count

    @reciepients_count = Recipient.count

    @no_of_user_last_month = @accounts.where.not(admin: true).where("accounts.created_at >?", 1.month.ago).count

    @currently_signed_in_users = @accounts.where(:last_seen_at=> Time.now.utc-5.minutes..Time.now).count

    @no_of_signed_in_users_today = @accounts.where("last_seen_at >= ?", Time.now.utc.beginning_of_day).count

    @super_admin_count = @accounts.where(admin: true).count

  end
end