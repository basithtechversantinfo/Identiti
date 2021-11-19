class DashboardController < ApplicationController
  require 'will_paginate/array'
  def index
    authorize nil, :is_account?, policy_class: AccountPolicy
    @per_page = params[:per_page].present? ? params[:per_page] : 10

    surveys = Survey.includes(:submissions, :recipients_surveys, :group, :allowed_recipients_surveys).undeleted_survey.where(group_id: $community_account.groups.where(archived: false).pluck(:id)).order(created_at: :desc)
    @all_surveys_count = surveys.to_a.size
    @all_surveys = surveys.paginate(page: params[:page], per_page: @per_page)
    @active_surveys = surveys.select {|survey| survey if active_survey_groups(survey)}
    @draft_surveys = surveys.select {|survey| survey if draft_survey_groups(survey)}
    @finished_surveys = surveys.select {|survey| survey if finished_survey_groups(survey)}
  end

  def active
    authorize nil, :is_account?, policy_class: AccountPolicy
    @per_page = params[:per_page].present? ? params[:per_page] : 10

    surveys = Survey.undeleted_survey.where(group_id: $community_account.groups.where(archived: false).pluck(:id)).order(created_at: :desc)

    
    @all_surveys = surveys
    @active_surveys = surveys.select {|survey| survey if active_survey_groups(survey)}
    @active_surveys_count = @active_surveys.to_a.size
    @active_surveys = @active_surveys.paginate(page: params[:page], per_page: @per_page)
    @draft_surveys = surveys.select {|survey| survey if draft_survey_groups(survey)}
    @finished_surveys = surveys.select {|survey| survey if finished_survey_groups(survey)}

  end

  def draft
    authorize nil, :is_account?, policy_class: AccountPolicy
    @per_page = params[:per_page].present? ? params[:per_page] : 10

    surveys = Survey.undeleted_survey.where(group_id: $community_account.groups.where(archived: false).pluck(:id)).order(created_at: :desc)

    @all_surveys = surveys
    @active_surveys = surveys.select {|survey| survey if active_survey_groups(survey)}
    @draft_surveys = surveys.select {|survey| survey if draft_survey_groups(survey)}
    @draft_surveys_count = @draft_surveys.to_a.size
    @draft_surveys = @draft_surveys.paginate(page: params[:page], per_page: @per_page)
    @finished_surveys = surveys.select {|survey| survey if finished_survey_groups(survey)}

  end


  def finished
    authorize nil, :is_account?, policy_class: AccountPolicy
    @per_page = params[:per_page].present? ? params[:per_page] : 10
    
    surveys = Survey.undeleted_survey.where(group_id: $community_account.groups.where(archived: false).pluck(:id)).order(created_at: :desc)

    @all_surveys = surveys
    @active_surveys = surveys.select {|survey| survey if active_survey_groups(survey)}
    @draft_surveys = surveys.select {|survey| survey if draft_survey_groups(survey)}
    @finished_surveys = surveys.select {|survey| survey if finished_survey_groups(survey)}
    @finished_surveys_count = @finished_surveys.to_a.size
    @finished_surveys = @finished_surveys.paginate(page: params[:page], per_page: @per_page)
  end

end
