class CustomizedPersonasController < ApplicationController
  # before_action :set_group
  # before_action :set_survey
  skip_before_action :authenticate_account!, :only => :show
  skip_authorize_resource :only => :show
  before_action :set_custom_persona, only: [:edit, :update, :destroy]

  def show
    # authorize nil, :is_account?, policy_class: AccountPolicy

    @customized_persona = CustomPersona.find_by_public_token(params[:id])
    @survey = @customized_persona.survey
    @recipients_results = @customized_persona.submissions.present? ? @survey.customized_aggregator_scoring(@customized_persona.submissions).result.freeze : nil

    @submissions_array = []
    @all_sus = []
    @grade = []
    @adjective = []
    @acceptable = []
    @percentile = []
    @show_hide_sus_btn = "show"
    @cust_show_hide_sus_btn = "show"
    
    @submission = @customized_persona.submissions
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
      format.js
    end
  end

  def new
    authorize nil, :is_account?, policy_class: AccountPolicy

    @customized_persona = CustomPersona.new

    respond_to do |format|
      format.js
    end
  end

  def create
    authorize nil, :is_account?, policy_class: AccountPolicy

    @customized_persona = CustomPersona.new(custom_persona_params)
    @customized_persona.account_id = $community_account.id
    @customized_persona.created_by_id = current_account.id
    @customized_persona.submission_ids = params[:custom_persona][:submission_ids].split(',')
    @customized_persona.save

    @survey = @customized_persona.survey


    display_bucket = []

    hash = Hash[['male', 'female'].map {|x| [x, 0]}]

    @customized_persona.submissions.each do |submission|
      if submission.data_json.to_s.match("Male").present?
        display_bucket.push "male"
      elsif submission.data_json.to_s.match("Female").present?
        display_bucket.push "female"
      elsif submission.data_json.to_s.match("Men").present?
        display_bucket.push "male"
      elsif submission.data_json.to_s.match("Women").present?
        display_bucket.push "female"
      elsif submission.recipient.gender.present?
        display_bucket.push submission.recipient.gender.downcase
      else
        display_bucket.push "no-image"
      end
    end 


    labels_with_count = display_bucket.inject(hash) {|h,i| h[i] += 1; h }

    get_gender = if labels_with_count["male"] == labels_with_count["female"]
                   'neutral-gender'
                 elsif labels_with_count["male"] > labels_with_count["female"]
                   'male'
                 elsif labels_with_count["female"] > labels_with_count["male"]
                   'female'
                 else
                   'no-image'
                 end

    if get_gender == 'male' || get_gender == 'female'
      @customized_persona.update(gender: get_gender, gender_image_slug: "gender/#{get_gender}-#{rand(1..99)}")
    else
      @customized_persona.update(gender: get_gender, gender_image_slug: "gender/#{get_gender}")
    end
    @per_page = params[:per_page].present? ? params[:per_page] : 10
    @p_page = params[:p_page].present? ? params[:p_page] : 1
    @c_page = params[:c_page].present? ? params[:c_page] : 1

    @survey_custom_personas = @survey.custom_personas
    @survey_custom_personas_count = @survey_custom_personas.count
    @survey_custom_personas = @survey_custom_personas.paginate(:page => @c_page, :per_page => @per_page)

    respond_to do |format|
      format.js
    end
  end

  def edit
    authorize nil, :is_account?, policy_class: AccountPolicy

    @survey = @customized_persona.survey
    @recipients_results = @customized_persona.submissions.present? ? @survey.customized_aggregator_scoring(@customized_persona.submissions).result.freeze : nil

    @submissions_array = []
    @all_sus = []
    @grade = []
    @adjective = []
    @acceptable = []
    @percentile = []
    @show_hide_sus_btn = "show"
    @cust_show_hide_sus_btn = "show"
    
    @submission = @customized_persona.submissions
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
      format.js
    end
  end

  def update
    authorize nil, :is_account?, policy_class: AccountPolicy

    @customized_persona.update(custom_persona_params)
    @survey = @customized_persona.survey

    respond_to do |format|
      format.js
    end
  end

  def destroy
    authorize nil, :is_account?, policy_class: AccountPolicy
    @survey = @customized_persona.survey
    @customized_persona.destroy
    @per_page = params[:per_page].present? ? params[:per_page] : 10
    @p_page = params[:p_page].present? ? params[:p_page] : 1
    @c_page = params[:c_page].present? ? params[:c_page] : 1

    @survey_custom_personas = @survey.custom_personas
    @survey_custom_personas_count = @survey_custom_personas.count
    @survey_custom_personas = @survey_custom_personas.paginate(:page => @c_page, :per_page => @per_page)
    respond_to do |format|
      format.js
    end
  end

  def export_pdf
    persona_tokens = params[:persona_tokens].split(',')
    if persona_tokens.empty?
      @customized_personas = CustomPersona.where(survey_id: params[:survey_id])
    else
      @customized_personas = CustomPersona.where(public_token: persona_tokens)
    end
    @survey = Survey.find(params[:survey_id])
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

  private
  def set_group
    @group = Group.find(params[:group_id])
  end

  def set_survey
    @survey = Survey.find(params[:survey_id])
  end

  def set_custom_persona
    @customized_persona = CustomPersona.includes(:survey, survey: [:custom_personas]).find(params[:id])
  end

  def custom_persona_params
    params.require(:custom_persona).permit(:title, :persona_name, :survey_id, :group_id, :account_id, :created_by_id,
                                           :data_json, submission_ids: [])
  end
end
