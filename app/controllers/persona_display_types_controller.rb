class PersonaDisplayTypesController < ApplicationController
  before_action :set_survey, only: [:display_type]

  def display_type
    @survey_submissions = @survey.submissions.allowed
    
    @submissions_array = []
    @all_sus = []
    @grade = []
    @adjective = []
    @acceptable = []
    @percentile = []
    @show_hide_sus_btn = "show"
    @cust_show_hide_sus_btn = "show"
    
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
      @answer_array = ["Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"]
      ques_count = @submissions_array.first.length

      @submissions_array.each_with_index do |sub_ary, index|
        for i in 0..(ques_count-1)
          new_idx = i + 1
          @survey_hash_1[index] << (@answer_array.find_index(@submissions_array[index].values[i]) + 1)
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
      format.js
    end
  end

  private
  def set_survey
    @survey = Survey.find(params[:survey_id]) rescue nil
    if @survey.nil?
      return redirect_to not_found_path(error_message: "survey_not_exists")
    end
  end
end
