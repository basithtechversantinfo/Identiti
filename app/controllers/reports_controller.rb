class ResultsController < ApplicationController
  require 'will_paginate/array'
  skip_before_action :authenticate_account!, :only => :show
  skip_authorize_resource :only => :show
  before_action :check_for_disabled_token, only: [:show]

  def index
    authorize nil, :is_account?, policy_class: AccountPolicy

    @per_page = params[:per_page].present? ? params[:per_page] : 10

    @groups = Group.includes(:surveys)
                  .references(:surveys)
                  .where('surveys.id IS not NULL').where(archived: false, account_id: $community_account.id).select {|g| g if g.surveys.where(survey_state: 1).present? }
    @groups = @groups.paginate(:page => params[:page], per_page: @per_page)
  end

  def show
    @group = @survey.group
    @results = @survey.submissions.present? ? @survey.aggregator.result.freeze : nil
    @recipients_results = @survey.submissions.present? ? @survey.aggregator_scoring.result.freeze : nil

    @per_page = params[:per_page].present? ? params[:per_page] : 10
    @p_page = params[:p_page].present? ? params[:p_page] : 1
    @c_page = params[:c_page].present? ? params[:c_page] : 1

    @survey_submissions = @survey.submissions.allowed
    @survey_submissions_count = @survey_submissions.to_a.size
    @survey_submissions_screened_count = @survey.submissions.notallowed.to_a.size
    @survey_submissions = @survey_submissions.paginate(:page => @p_page, :per_page => @per_page)
    @survey_custom_personas = @survey.custom_personas
    @survey_custom_personas_count = @survey.custom_personas.to_a.size
    @survey_custom_personas = @survey_custom_personas.paginate(:page => @c_page, :per_page => @per_page)

    @submissions_array = []
    @all_sus = []
    @grade = []
    @adjective = []
    @acceptable = []
    @percentile = []
    
    @submission = @survey_submissions
    @submission.each do |submission|
      @survey_sub = submission.survey
      @survey_sub.categories_surveys.each do |cat_sur|
        @category = cat_sur.category
        if @category && @category.display_type == "system_usability_scale"
          @submissions_array << submission.data_json["data"]["#{cat_sur.category_id}"]
        end
      end
    end

    if @submissions_array.size != 0
      @survey_hash_1 = Hash.new{|h,k| h[k] = [] }
      @answer_array = ["Strongly disagree", "Disagree", "Neutral", "Agree", "Strongly agree"]
      ques_count = @submissions_array.first.length

      @submissions_array.each_with_index do |sub_ary, index|
        for i in 0..(ques_count-1)
          new_idx = i + 1
          @survey_hash_1[index] << (@answer_array.find_index(@submissions_array[index].values[i]) + 1) if @answer_array.find_index(@submissions_array[index].values[i]).present?
        end
      end

      if @survey_hash_1.length != 0
        @sus_cal_1 = {}
        @survey_hash_1.each{ |key, val|
          @a = []
          val.each.with_index(1) do |v, i|
            if i.even?
              @a << 5 - v
            else
              @a << v - 1
            end
          end

          sus = ( (@a.inject(0) { |sum, x| sum + x }) ) * 2.5
          @all_sus << sus
        }
        
        @avg_sus = (@all_sus.inject(0) { |sum, x| sum + x } / @all_sus.size).round(2)

        if (@avg_sus <= 51.6)
          @grade << "F"
        elsif ((51.7 <= @avg_sus) && (@avg_sus <= 62.6))
          @grade << "D"
        elsif ((62.7 <= @avg_sus) && (@avg_sus <= 72.5))
          @grade << "C"
        elsif ((72.6 <= @avg_sus) && (@avg_sus <= 78.8))
          @grade << "B"
        elsif ((78.9 <= @avg_sus) && (@avg_sus <= 100))
          @grade << "A"
        end

        if @avg_sus <= 25
          @adjective << "Worst Imaginable"
        elsif (25.1 <= @avg_sus && @avg_sus <= 51.6)
          @adjective << "Poor"
        elsif (51.7 <= @avg_sus && @avg_sus <= 62.6)
          @adjective << "OK"
        elsif (62.7 <= @avg_sus && @avg_sus <= 72.5)
          @adjective << "Good"
        elsif (72.6 <= @avg_sus && @avg_sus <= 84.0)
          @adjective << "Excellent"
        elsif (84.1 <= @avg_sus && @avg_sus <= 100)
          @adjective << "Best Imaginable"
        end

        if @avg_sus <= 51.6
          @acceptable << "Not Acceptable"
        elsif (51.7 <= @avg_sus && @avg_sus <= 71.0)
          @acceptable << "Marginal"
        elsif (71.1 <= @avg_sus && @avg_sus <= 100)
          @acceptable << "Acceptable"
        end

        if @avg_sus <= 25
          @percentile = 1.9
        elsif (25.1 <= @avg_sus && @avg_sus <= 51.6)
          @percentile = 14
        elsif (51.7 <= @avg_sus && @avg_sus <= 62.6)
          @percentile = 34
        elsif (62.7 <= @avg_sus && @avg_sus <= 64.9)
          @percentile = 40
        elsif (65.0 <= @avg_sus && @avg_sus <= 71.0)
          @percentile = 59
        elsif (71.1 <= @avg_sus && @avg_sus <= 72.5)
          @percentile = 64
        elsif (72.6 <= @avg_sus && @avg_sus <= 74.0)
          @percentile = 69
        elsif (74.1 <= @avg_sus && @avg_sus <= 77.1)
          @percentile = 79
        elsif (77.2 <= @avg_sus && @avg_sus <= 78.8)
          @percentile = 84
        elsif (78.9 <= @avg_sus && @avg_sus <= 80.7)
          @percentile = 89
        elsif (80.8 <= @avg_sus && @avg_sus <= 84.0)
          @percentile = 95
        elsif (84.1 <= @avg_sus && @avg_sus <= 100)
          @percentile = 100
        end

        @grade = @grade.uniq
        @adjective = @adjective.uniq
        @acceptable = @acceptable.uniq
      end
    else
      @avg_sus = 0
      @percentile = 0
    end
    
    respond_to do |format|
      format.html {render :layout => 'reports'}
    end
  end

  def disable_public_link
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @survey = Survey.find(params[:survey_id])
    @survey.update(public_token: nil)
  end

  def generate_public_link
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @survey = Survey.find(params[:survey_id])
    public_token = Digest::SHA1.hexdigest([Time.now, rand(34534656)].join)
    @survey.update(public_token: public_token)
  end

  private

  def check_for_disabled_token
    @survey = Survey.find_by_public_token(params[:id])
    
    if @survey.nil?
      return redirect_to not_found_path(error_message: "report_shared")
    end
  end
end
