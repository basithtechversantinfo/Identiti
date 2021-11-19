class PersonasController < ApplicationController
  layout 'frontend'
  
  def index
  	authorize nil, :is_account?, policy_class: AccountPolicy
    @per_page = params[:per_page].present? ? params[:per_page] : 10

    surveys = Survey.includes(:submissions, :recipients_surveys, :group, :allowed_recipients_surveys).undeleted_survey.where(survey_type: 2, group_id: $community_account.groups.where(archived: false).pluck(:id)).order(created_at: :desc)
    @all_surveys_count = surveys.to_a.size
    @all_surveys = surveys.paginate(page: params[:page], per_page: @per_page)
    @active_surveys = surveys.select {|survey| survey if active_survey_groups(survey)}
    @draft_surveys = surveys.select {|survey| survey if draft_survey_groups(survey)}
    @finished_surveys = surveys.select {|survey| survey if finished_survey_groups(survey)}
  end

end
