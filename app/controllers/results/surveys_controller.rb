class Results::SurveysController < ApplicationController
  require 'will_paginate/array'
  before_action :set_group
  before_action :set_survey, only: [:results, :respondent_with_answers]

  def all
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize @group.account, :can_view?, policy_class: AccountPolicy
    
    @per_page = params[:per_page].present? ? params[:per_page] : 10

    surveys = @group.surveys.undeleted_survey.where.not(survey_state: 0).order(created_at: :desc)

    @all_surveys = surveys
    @active_surveys = surveys.select {|survey| survey if active_survey_groups(survey)}
    @finished_surveys = surveys.select {|survey| survey if finished_survey_groups(survey)}
    @all_surveys_count = @all_surveys.to_a.size
    @all_surveys = @all_surveys.paginate(:page => params[:page], per_page: @per_page)

  end

  def active
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize @group.account, :can_view?, policy_class: AccountPolicy

    @per_page = params[:per_page].present? ? params[:per_page] : 10

    surveys = @group.surveys.undeleted_survey.where.not(survey_state: 0).order(created_at: :desc)

    @all_surveys = surveys
    @active_surveys = surveys.select {|survey| survey if active_survey_groups(survey)}
    @finished_surveys = surveys.select {|survey| survey if finished_survey_groups(survey)}
    @active_surveys_count = @active_surveys.to_a.size
    @active_surveys = @active_surveys.paginate(:page => params[:page], :per_page => @per_page)
  end

  def finished
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize @group.account, :can_view?, policy_class: AccountPolicy
    @per_page = params[:per_page].present? ? params[:per_page] : 10

    surveys = @group.surveys.undeleted_survey.where.not(survey_state: 0).order(created_at: :desc)

    @all_surveys = surveys
    @active_surveys = surveys.select {|survey| survey if active_survey_groups(survey)}
    @finished_surveys = surveys.select {|survey| survey if finished_survey_groups(survey)}
    @finished_surveys_count = @finished_surveys.to_a.size
    @finished_surveys = @finished_surveys.paginate(:page => params[:page], :per_page => @per_page)
  end

  def results
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize @survey.group.account, :can_view?, policy_class: AccountPolicy
    @locale = params[:locale]
    @per_page = params[:per_page].present? ? params[:per_page] : 10
    @p_page = params[:p_page].present? ? params[:p_page] : 1
    @c_page = params[:c_page].present? ? params[:c_page] : 1

    @sort_question = @survey.categories_surveys.includes(category: [:questions]).collect{|c| c.category.questions.find_by(sort_results: true)}.reject(&:blank?).take(1).first
    if @sort_question.present?

        @sortable_options = @sort_question.question_labels.select(:id,:label)

      @survey_ans = @survey.aggregator_scoring.result["recipients"][@sort_question.category.id.to_s][@sort_question.id.to_s] 
      @sorted_recipients = {}
      @sortable_options.each do |option|
        label = option.label
        @sorted_recipients[label.to_s] = @survey_ans.to_h.map{ |m|  m[1].key([option.label])}.reject(&:blank?)
      end
      if @sort_question.other_specify == "Yes"
        o_ids = []
        e_options = @sortable_options.pluck(:label)
        @survey_ans.to_h.map{ |m|  m[1].each{ |l, v|
            if v.include?("other")  
             o_ids << l
            else
              o_ids << l if  (v - e_options).present?
            end 
          }
        }.reject(&:blank?)
        @sorted_recipients["other".to_s] = o_ids
      end
    end
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
    @submissions_array = @submissions_array.compact

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
  end

  def respondent_with_answers
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize @survey.group.account, :can_view?, policy_class: AccountPolicy

    @recipients_results = @survey.submissions.present? ? @survey.aggregator_scoring.result["recipients"].freeze : nil
    @survey_submissions = @survey.submissions.allowed

    @submissions_array = []
    @all_sus = []
    @grade = []
    @adjective = []
    @acceptable = []
    @percentile = []
    @show_hide_sus_btn = "show"
    
    @submission = Submission.where(id: params[:submission_id])
    @submission.each do |submission|
      @survey_sub = submission.survey
      @survey_sub.categories_surveys.each do |cat_sur|
        @category = cat_sur.category
        if @category && @category.display_type == "system_usability_scale"
          @submissions_array << submission.data_json["data"]["#{cat_sur.category_id}"]
        end
      end
    end
    @submissions_array = @submissions_array.compact

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
  end

  def export_pdf
    submission_ids = params[:submission_ids].split(',')
    if submission_ids.empty?
      set_survey
      allowed_ids = @survey.submissions.present? ? @survey.submissions.allowed.ids : ""
      @results = @survey.submissions.present? ? @survey.pdf_aggregator(allowed_ids).result.freeze : nil
      @recipients_results = @survey.submissions.present? ? @survey.pdf_aggregator_scoring(allowed_ids).result["recipients"].freeze : nil
    else
      @survey = Survey.find(params[:id])
      @results = @survey.submissions.present? ? @survey.pdf_aggregator(submission_ids).result.freeze : nil
      @recipients_results = @survey.submissions.present? ? @survey.pdf_aggregator_scoring(submission_ids).result["recipients"].freeze : nil
    end

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

    @submissions_array = @submissions_array.compact


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
            format.html
            format.pdf do
              render pdf: "e_persona", layout: "pdf.html", show_as_html: params.key?('debug'), viewport_size: '1280x1024', javascript_delay: 3000, disposition: 'attachment'
            end
        end
  end

  def export_summary_pdf
    set_survey
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize @survey.group.account, :can_view?, policy_class: AccountPolicy
    
    @survey_submissions = @survey.submissions.allowed
    @submissions_array = []
    @all_sus = []
    @grade = []
    @adjective = []
    @acceptable = []
    @percentile = []
    @show_hide_sus_btn = "show"
    
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

    @submissions_array = @submissions_array.compact


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
            format.html
            format.pdf do
              render pdf: "e_persona_summary", layout: "pdf.html", show_as_html: params.key?('debug'), viewport_size: '1280x1024', javascript_delay: 1000, disposition: 'attachment'
            end
        end
  end

  private
  def set_group
    params[:report_id] = params[:result_id]
    @group = Group.where(archived: false).find(params[:report_id]) rescue nil
    if @group.nil?
      return redirect_to not_found_path(error_message: "group_not_exists")
    end
    @survey_count_by_states = @group.surveys.group(:survey_state).count
  end

  def set_survey
    @survey = @group.surveys.includes(:submissions, :categories_surveys, :custom_personas, :categories, categories: [:questions, questions: [:question_labels, :label_template]], categories_surveys: [:category]).find(params[:id]) rescue nil
    if @survey.nil?
      return redirect_to not_found_path(error_message: "survey_not_exists")
    end
    @results = @survey.submissions.present? ? @survey.aggregator.result.freeze : nil
    @recipients_results = @survey.submissions.present? ? @survey.aggregator_scoring.result.freeze : nil
  end 
end
