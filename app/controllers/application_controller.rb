class ApplicationController < ActionController::Base
  protect_from_forgery
  include Pundit
  include CscHelper

  rescue_from Pundit::NotAuthorizedError, with: :account_not_authorized

  rescue_from Wicked::Wizard::InvalidStepError, with: :account_not_authorized

  rescue_from ActiveRecord::RecordNotFound, with: :page_not_found_redirect

  before_action :authenticate_account!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  before_action :set_counter_zero
  before_action :set_community_account
  before_action :set_boolean_false
  before_action :check_required_password
  before_action :set_last_seen_at, if: proc { account_signed_in? && (session[:last_seen_at] == nil || session[:last_seen_at] < 15.minutes.ago) }
  layout :get_layout

  def pundit_user
    current_account
  end

  def get_layout
    if account_signed_in?
      if current_account.admin?
        'application'
      else
        'frontend'
      end
    else
      'devise'
    end
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    { locale: I18n.locale }
  end


  $counter = 0
  $boolean = false

  def set_counter_zero
    $counter = 0
  end

  def set_boolean_false
    $boolean = false
  end

  def set_community_account
    if account_signed_in?

      $community_account =
          begin
            if current_account.account_type == 'user'
              Account.find(current_account.account_id)
            else
              current_account
            end
          rescue
            current_account
          end

    else

      $community_account = nil

    end
  end

  def active_survey_groups(survey)
    from = Time.now
    to = survey.delivery_end_at

    if Survey.survey_states.key(1) == survey.survey_state
      if to.present?
        if from.to_time.to_i > to.to_time.to_i
          false
        else
          true
        end
      else
        false
      end
    else
      false
    end
  end

  def finished_survey_groups(survey)
    from = Time.now
    to = survey.delivery_end_at

    if Survey.survey_states.key(1) == survey.survey_state
      if to.present?
        if from.to_time.to_i > to.to_time.to_i
          true
        else
          false
        end
      else
        false
      end
    else
      false
    end
  end

  def draft_survey_groups(survey)
    from = Time.now
    to = survey.delivery_end_at

    if Survey.survey_states.key(1) == survey.survey_state
      if to.present?
        if from.to_time.to_i > to.to_time.to_i
          false
        else
          false
        end
      else
        true
      end
    else
      true
    end
  end

  def user_is_logged_in?
    if !session[:oktastate]
      print("this is not logged in")
      redirect_to account_oktaoauth_omniauth_authorize_path
    end
  end

  private

  def set_last_seen_at
    current_account.update_attribute(:last_seen_at, Time.current)
    session[:last_seen_at] = Time.current
  end

  def account_not_authorized
    flash[:error] = "You are not authorized to perform this action."

    self.response_body = nil
    redirect_to(request.referrer || if account_signed_in? and current_account.admin?
                                      admin_path
                                    else
                                      root_path
                                    end)
  end


  def page_not_found_redirect
    return redirect_to not_found_path(error_message: "page_not")
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:your_name, :company, :company_name, :company_email, :sender_email])
    devise_parameter_sanitizer.permit(:account_update, keys: [:your_name, :company, :company_name, :company_email, :sender_email, :image, email_notification_type_ids: []])
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_path
    else
      if resource.require_new_password == true
        user_passwords_path
      else
        root_path
      end
    end
  end

  def check_required_password
    if account_signed_in? and current_account.account_type == 'user'
      if current_account.require_new_password == true and controller_name != 'user_passwords'
        redirect_to user_passwords_path
      elsif current_account.require_new_password == false and controller_name == 'user_passwords'
        redirect_to root_path
      else
        return
      end
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    new_account_session_path
  end
end
