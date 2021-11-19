class ErrorsController < ApplicationController
  skip_before_action :authenticate_account!, :only => :not_found
  skip_authorize_resource :only => :not_found
  layout false
  
  def not_found
    @message = params[:error_message].present? ? construct_message(params[:error_message]) : "#{t 'errors.page_not_found'}"
  end

  private

  def construct_message message
    if message == "report_shared"
      "#{t 'errors.message'}"
    elsif message == "survey_not_exists"
      "#{t 'errors.survey_not_exists'}"
    elsif message == "group_not_exists"
      "#{t 'errors.group_not_exists'}"
    else
      "#{t 'errors.page_not_found'}"
    end
  end
end
