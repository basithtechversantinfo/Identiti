class SurveysController < ApplicationController
  require 'will_paginate/array'
  layout "survey_build", only: [:new, :create, :edit, :preview_survey, :success, :preview_survey_branching]
  before_action :set_survey, only: [:show, :edit, :update, :destroy, :preview_survey, :preview_survey_branching, :save_as_a_template_create, :success, :respondent_with_answers]
  # before_action :set_template_theme, only: [:new]
  # before_action :set_group

  def respondent_with_answers
    authorize nil, :is_account?, policy_class: AccountPolicy
    @sort_question = @survey.categories_surveys.includes(category: [:questions]).collect{|c| c.category.questions.find_by(sort_results: true)}.reject(&:blank?).take(1).first
    if @sort_question.present?

        @sortable_options = @sort_question.question_labels.select(:id,:label)

      @survey_ans = @survey.aggregator.result["recipients"][@sort_question.category_id.to_s][@sort_question.id.to_s].freeze 
      @sorted_recipients = {}
      @sortable_options.each do |option|
        a_ids=[]
        label = option.label
        # @sorted_recipients[label.to_s] = @survey_ans.to_h.map{ |m|  m[1].key([option.label])}.reject(&:blank?)
        @survey_ans.to_h.map{ |m|  m[1].each{ |l, v| a_ids << l if v.include?(label.to_s)  }}.reject(&:blank?)
        @sorted_recipients[label.to_s] = a_ids
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
    @recipients_results = @survey.submissions.present? ? @survey.aggregator.result["recipients"][params[:category_id]][params[:question_id]].freeze : nil
    question = Question.find(params[:question_id])
    @question_type = question.question_type
    @question_title = params[:question_title]
    @answered = params[:answered]
    @skipped = params[:skipped]
  end

  def success
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize @survey.group.account, :can_view?, policy_class: AccountPolicy
    authorize $community_account, :can_access_preview?, policy_class: AccountPolicy
  end

  def preview_survey
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize @survey.group.account, :can_view?, policy_class: AccountPolicy
    authorize $community_account, :can_access_preview?, policy_class: AccountPolicy

    respond_to do |format|
      format.html
    end
  end

  def preview_survey_branching
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize @survey.group.account, :can_view?, policy_class: AccountPolicy
    authorize $community_account, :can_access_preview?, policy_class: AccountPolicy

    respond_to do |format|
      format.html
    end
  end

  def save_as_a_template
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @template_theme = TemplateTheme.new
    @survey_industries = Survey.find(params[:id]).industries.ids

    respond_to do |format|
      format.js
    end
  end

  def save_as_a_template_create
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @template_theme = TemplateTheme.new(template_theme_params)
    @template_theme.account_id = $community_account.id
    @template_theme.save

    @survey.categories_surveys.each do |c_s|
      master_category = Category.find(c_s.category_id)
      cloned_category = master_category.deep_clone include: [:questions => :question_labels, questions:  [ :question_labels => :image_attachment]]

      cloned_category.account_id = $community_account.id
      cloned_category.block_relation_type = "saved_as_template"

      cloned_category.survey_id = nil
      # cloned_category.master_id = master_category.id
      cloned_category.industry_ids = master_category.industry_ids

      cloned_category.save!

      CategoriesTemplateTheme.create(template_theme_id: @template_theme.id, category_id: cloned_category.id, position: c_s.position)
      q_labels = cloned_category.questions.first.is_branching? ? cloned_category.questions.first.question_labels.update_all(branch_to: 0) :  ""  rescue nil
    end


    respond_to do |format|
      format.js
    end
  end

  def index
    authorize nil, :is_account?, policy_class: AccountPolicy

    @per_page = params[:per_page].present? ? params[:per_page] : 10

    surveys = Survey.includes(:submissions, :recipients_surveys, :group, :allowed_recipients_surveys).undeleted_survey.where.not(survey_type: 2).where(group_id: $community_account.groups.where(archived: false).pluck(:id)).order(created_at: :desc)
    @all_surveys_count = surveys.to_a.size
    @all_surveys = surveys.paginate(page: params[:page], per_page: @per_page)
    @active_surveys = surveys.select {|survey| survey if active_survey_groups(survey)}
    @draft_surveys = surveys.select {|survey| survey if draft_survey_groups(survey)}
    @finished_surveys = surveys.select {|survey| survey if finished_survey_groups(survey)}
    render(:layout => "layouts/frontend")
  end

  def show
    authorize nil, :is_account?, policy_class: AccountPolicy
  end

  def new
    authorize nil, :is_account?, policy_class: AccountPolicy
    if params[:build_own] != "true"
      set_template_theme()
      authorize @template_theme, :can_view?
    end
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    check_limitations_template
    @survey = Survey.new
  end

  def edit
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    # if Survey.survey_states.key(1) == @survey.survey_state
    #   redirect_to results_report_survey_path(@survey.group_id, @survey)
    # else
    redirect_to survey_step_path(@survey, 'setup')
    # end
  end

  def new_group
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @group = Group.new
    respond_to do |format|
      format.js
    end
  end

  def create_group
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @group = Group.new(group_params)
    @group.account_id = $community_account.id
    @group.created_by_id = current_account.id
    @group.save

    if params[:group][:image].present?
      image = MiniMagick::Image.open(File.open(params[:group][:image].tempfile).path)
      image.path
      image.format "png"
      image.write "output.png"

      path = image.path

      File.open(path) do |io|
        @group.image.attach(io: io, filename: "output.png", content_type: "image/png")
      end
    end

    respond_to do |format|
      format.js
    end
  end


  def clone
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    check_limitations
    @survey = Survey.new

    respond_to do |format|
      format.js
    end
  end

  def clone_submit
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy
    @from_loc = params[:from_loc].present? ? params[:from_loc] : ""

    master_survey = Survey.find(params[:survey][:survey_id])
    cloned_survey = master_survey.deep_clone include: [:recipients_surveys, :lists]

    if Survey.where(group_id: params[:survey][:group_id], title: master_survey.title).present?
      cloned_survey.title = master_survey.title + " (#{Group.find(params[:survey][:group_id]).surveys.where("title LIKE :query", query: "%#{master_survey.title}%").count})"
    end

    cloned_survey.survey_token = nil
    cloned_survey.delivery_time = nil
    cloned_survey.delivery_start_at = nil
    cloned_survey.delivery_end_at = nil
    cloned_survey.survey_state = 0
    cloned_survey.created_by_id = current_account.id
    cloned_survey.group_id = params[:survey][:group_id]
    cloned_survey.industry_ids = master_survey.industry_ids
    cloned_survey.enable_share = true


    if cloned_survey.save!
      cloned_survey.recipients_surveys.where(allow_survey: "true").update_all(allow_survey: false) if cloned_survey.non_email_link?
      master_survey.categories_surveys.each do |c_s|

        master_category = Category.includes(questions: [:question_labels]).find(c_s.category_id)
        cloned_category = master_category.deep_clone include: [:questions => :question_labels, questions:  [ :question_labels => :image_attachment]]

        cloned_category.account_id = $community_account.id
        # cloned_category.cloned = false
        # cloned_category.cloned_from = nil
        # cloned_category.master_id = master_category.id

        cloned_category.survey_id = cloned_survey.id
        cloned_category.industry_ids = master_category.industry_ids

        cloned_category.save!

        CategoriesSurvey.create!(survey_id: cloned_survey.id, category_id: cloned_category.id, position: c_s.position)
      end
      q_labels = cloned_survey.categories.select { |e| e.questions.first.is_branching }.map{|e| e.questions}.flatten.map{|c| c.question_labels.ids}.flatten rescue nil
      
      QuestionLabel.where(id: q_labels ).update_all(branch_to: 0) unless q_labels.nil?

      flash.now[:success] = 'Item was copied successfully to "' + cloned_survey.group.title + '"'
      if @from_loc.present?
        if @from_loc == "dashboard_all"
          surveys = Survey.includes(:submissions, :recipients_surveys, :group, :allowed_recipients_surveys).undeleted_survey.where(group_id: $community_account.groups.where(archived: false).pluck(:id)).order(created_at: :desc)

          @all_surveys_count = surveys.to_a.size
          @all_surveys = surveys.paginate(:page => params[:page], per_page: @per_page)
          @group = Group.find(params[:survey][:group_id])
          @active_surveys = surveys.select {|survey| survey if active_survey_groups(survey)}
          @draft_surveys = surveys.select {|survey| survey if draft_survey_groups(survey)}
          @finished_surveys = surveys.select {|survey| survey if finished_survey_groups(survey)}
        else
          @group = Group.find(params[:main_group_id])
          surveys = @group.surveys.undeleted_survey.order(created_at: :desc)
          @all_surveys = surveys.paginate(page: params[:page], per_page: @per_page)
          @all_surveys_count = surveys.to_a.size
          @active_surveys = surveys.select {|survey| survey if active_survey_groups(survey)}
          @draft_surveys = surveys.select {|survey| survey if draft_survey_groups(survey)}
          @finished_surveys = surveys.select {|survey| survey if finished_survey_groups(survey)}
        end
      end
    else

      flash.now[:error] = 'Something went wrong please try again.'

    end

    respond_to do |format|
      format.js
    end
  end


  def duplicate
    # p params
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    check_limitations
    @survey = Survey.new

    respond_to do |format|
      format.js
    end
  end

  def duplicate_submit
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy
    @from_loc = params[:from_loc].present? ? params[:from_loc] : ""

    master_survey = Survey.find(params[:survey][:survey_id])
    cloned_survey = master_survey.deep_clone include: [:recipients_surveys, :lists]

    if Survey.where(group_id: params[:survey][:group_id], title: master_survey.title).present?
      cloned_survey.title = master_survey.title + " (#{Group.find(params[:survey][:group_id]).surveys.where("title LIKE :query", query: "%#{master_survey.title}%").count})"
    end

    cloned_survey.survey_token = nil
    cloned_survey.delivery_time = nil
    cloned_survey.delivery_start_at = nil
    cloned_survey.delivery_end_at = nil
    cloned_survey.survey_state = 0
    cloned_survey.survey_sent_at = nil
    cloned_survey.created_by_id = current_account.id
    cloned_survey.group_id = params[:survey][:group_id]
    cloned_survey.industry_ids = master_survey.industry_ids
    cloned_survey.enable_share = true

    if cloned_survey.save!
      cloned_survey.recipients_surveys.where(allow_survey: "true").update_all(allow_survey: false) if cloned_survey.non_email_link?

      master_survey.categories_surveys.each do |c_s|

        master_category = Category.includes(questions: [:question_labels]).find(c_s.category_id)
        cloned_category = master_category.deep_clone include: [:questions => :question_labels, questions:  [ :question_labels => :image_attachment]]

        cloned_category.account_id = $community_account.id
        # cloned_category.cloned = false
        # cloned_category.cloned_from = nil
        # cloned_category.master_id = master_category.id

        cloned_category.survey_id = cloned_survey.id
        cloned_category.industry_ids = master_category.industry_ids

        cloned_category.save!

        CategoriesSurvey.create!(survey_id: cloned_survey.id, category_id: cloned_category.id, position: c_s.position)
      end
      q_labels = cloned_survey.categories.select { |e| e.questions.first.is_branching }.map{|e| e.questions}.flatten.map{|c| c.question_labels.ids}.flatten rescue nil
      
      QuestionLabel.where(id: q_labels ).update_all(branch_to: 0) unless q_labels.nil?
      flash.now[:success] = 'Item was duplicated successfully to "' + cloned_survey.group.title + '"'
      @per_page = params[:per_page].present? ? params[:per_page] : 10

      if @from_loc.present?
        if @from_loc == "dashboard_all"
          surveys = Survey.includes(:submissions, :recipients_surveys, :group, :allowed_recipients_surveys).undeleted_survey.where(group_id: $community_account.groups.where(archived: false).pluck(:id)).order(created_at: :desc)

          @all_surveys_count = surveys.to_a.size
          @all_surveys = surveys.paginate(:page => params[:page], per_page: @per_page)
          @group = Group.find(params[:survey][:group_id])
          @active_surveys = surveys.select {|survey| survey if active_survey_groups(survey)}
          @draft_surveys = surveys.select {|survey| survey if draft_survey_groups(survey)}
          @finished_surveys = surveys.select {|survey| survey if finished_survey_groups(survey)}
        else
          @group = Group.includes(:surveys).find(params[:main_group_id])
          # @main_group = Group.find(params[:group_id])
          surveys = @group.surveys.undeleted_survey.order(created_at: :desc)
          @all_surveys = surveys.paginate(page: params[:page], per_page: @per_page)
          @all_surveys_count = surveys.to_a.size
          @active_surveys = surveys.select {|survey| survey if active_survey_groups(survey)}
          @draft_surveys = surveys.select {|survey| survey if draft_survey_groups(survey)}
          @finished_surveys = surveys.select {|survey| survey if finished_survey_groups(survey)}
        end
      end
    else

      flash.now[:error] = 'Something went wrong please try again.'

    end

    respond_to do |format|
      format.js
    end
  end

  def move
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @survey = Survey.new

    respond_to do |format|
      format.js
    end
  end

  def move_submit
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy
    @from_loc = params[:from_loc].present? ? params[:from_loc] : ""

    @survey = Survey.find(params[:survey][:survey_id])
    @survey.group_id = params[:survey][:group_id]
    if @survey.save!
      @survey.custom_personas.update_all(group_id: params[:survey][:group_id])
      if @from_loc == "dashboard_all"
        surveys = Survey.undeleted_survey.where(group_id: $community_account.groups.where(archived: false).pluck(:id)).order(created_at: :desc)

        @all_surveys_count = surveys.to_a.size
        @all_surveys = surveys.paginate(:page => params[:page], per_page: @per_page)
        @group = Group.find(params[:survey][:group_id])
        @active_surveys = surveys.select {|survey| survey if active_survey_groups(survey)}
        @draft_surveys = surveys.select {|survey| survey if draft_survey_groups(survey)}
        @finished_surveys = surveys.select {|survey| survey if finished_survey_groups(survey)}
      else
        @group = Group.find(params[:main_group_id])
        surveys = @group.surveys.undeleted_survey.order(created_at: :desc)
        @all_surveys = surveys.paginate(page: params[:page], per_page: @per_page)
        @all_surveys_count = surveys.to_a.size
        @active_surveys = surveys.select {|survey| survey if active_survey_groups(survey)}
        @draft_surveys = surveys.select {|survey| survey if draft_survey_groups(survey)}
        @finished_surveys = surveys.select {|survey| survey if finished_survey_groups(survey)}
      end

      flash.now[:success] = 'Item was moved successfully to "' + @survey.group.title + '"'

    else

      flash.now[:error] = 'Something went wrong please try again.'

    end

    respond_to do |format|
      format.js
    end
  end

  def create
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @survey = Survey.new(survey_params)
    @survey.created_by_id = current_account.id

    if params[:survey][:survey_type].present? && params[:survey][:survey_type].to_s == "persona"
      @survey.survey_type = 2
    else
      @survey.survey_type = 1
    end

    if @survey.template_theme.present?
      @survey.thank_you_page = @survey.template_theme.thank_you_page
      @survey.welcome_page = @survey.template_theme.welcome_page
    end

    respond_to do |format|
      if @survey.save!
        if params[:survey][:build_own].present? && params[:survey][:build_own].to_s == "true"
          if params[:survey][:survey_type].present? && params[:survey][:survey_type].to_s == "persona"
            master_category = Category.find_by_id(1)
            cloned_category = master_category.deep_clone include: [:questions => :question_labels, questions:  [ :question_labels => :image_attachment]]

            cloned_category.account_id = $community_account.id
            cloned_category.block_relation_type = nil

            cloned_category.survey_id = @survey.id

            if master_category.block_relation_type != "saved_as_template"
              cloned_category.cloned = false
              cloned_category.cloned_from = nil
              cloned_category.master_id = master_category.id
            end

            cloned_category.industry_ids = master_category.industry_ids

            cloned_category.save!

            CategoriesSurvey.create!(survey_id: @survey.id, category_id: cloned_category.id, position: 1)
          end
        else
          @survey.template_theme.categories_template_themes.each do |c_s|
            master_category = Category.find(c_s.category_id)
            cloned_category = master_category.deep_clone include: [:questions => :question_labels, questions:  [ :question_labels => :image_attachment]]

            cloned_category.account_id = $community_account.id
            cloned_category.block_relation_type = nil

            cloned_category.survey_id = @survey.id

            if master_category.block_relation_type != "saved_as_template"
              cloned_category.cloned = false
              cloned_category.cloned_from = nil
              cloned_category.master_id = master_category.id
            end

            cloned_category.industry_ids = master_category.industry_ids

            cloned_category.save!

            CategoriesSurvey.create!(survey_id: @survey.id, category_id: cloned_category.id, position: c_s.position)
          end
        end

        format.html { redirect_to survey_step_path(@survey, 'build') }
      else
        format.html { render :new }
      end
    end
  end

  def update
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    respond_to do |format|
      if @survey.update(survey_params)
        format.html { redirect_to group_surveys_path(@group) }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    # @survey.destroy
    @survey.update(deleted_at: Time.now)
    respond_to do |format|
      if params[:survey_type].present?
        if params[:survey_type] == "persona" 
          format.html { redirect_to personas_path, notice: 'Item was deleted successfully' }
        elsif params[:survey_type] == "dashboard" 
          format.html { redirect_to root_path, notice: 'Item was deleted successfully' }
        else
          format.html { redirect_to surveys_path, notice: 'Item was deleted successfully' }
        end
      else
        format.html { redirect_to all_group_surveys_path(@survey.group_id), notice: 'Item was deleted successfully' }
      end
    end
  end

   def disable_or_enable_shared_link
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy
    @locale = params[:locale]
    @survey = Survey.find(params[:survey_id])
    value = !@survey.enable_share?
    @survey.update_column(:enable_share, value)
  end

  private
  def set_survey
    @survey = Survey.find(params[:id])

    if @survey.nil?
      return redirect_to not_found_path(error_message: "survey_not_exists")
    end
  end

  def set_group
    @group = Group.find(params[:group_id])
  end

  def set_template_theme
    @template_theme = TemplateTheme.find(params[:template_id])
  end

  def survey_params
    params.require(:survey).permit(:title, :created_by_id, :email_from, :email_sender, :email_subject, :delivery_end_at, :delivery_start_at, :delivery_time, :group_id, :template_theme_id, :survey_type, industry_ids: [])
  end

  def group_params
    params.require(:group).permit(:title, :account_id, :created_by_id)
  end

  def template_theme_params
    params.require(:template_theme).permit(:title, :account_id, industry_ids: [])
  end

  def check_limitations
    @mastersurvey = Survey.find(params[:survey_id])
    q_check = $community_account.question_limit <= @mastersurvey.categories_surveys.collect{|c| c.category.questions.to_a.size}.sum
    b_check = $community_account.block_limit <= @mastersurvey.categories_surveys.to_a.size
    if $community_account.survey_limit <= Survey.undeleted_survey.where(created_by_id: $community_account.id).to_a.size
      flash[:warning] = "You have reached your maximum survey amount of (#{$community_account.survey_limit})."
      respond_to do |format|
        format.html {redirect_to root_path}
        format.js{

          render :js => "window.location.href = '#{root_path}'" 
          return
        }
      end
    elsif q_check || b_check
      if q_check
        flash[:warning] = "You have reached your maximum number of (#{$community_account.question_limit}) questions."
      elsif b_check
        flash[:warning] ="You have reached your maximum number of (#{$community_account.block_limit}) blocks."
      end
      respond_to do |format|
        format.html {redirect_to root_path}
        format.js{

          render :js => "window.location.href = '#{root_path}'" 
          return
        }
      end
    end
  end

  def check_limitations_template
    @mastertemplate = TemplateTheme.find(params[:template_id]) rescue nil
    if @mastertemplate.present?
      q_check = $community_account.question_limit < @mastertemplate.categories.collect{|c| c.questions.to_a.size}.sum
      b_check = $community_account.block_limit <= @mastertemplate.categories.to_a.size
      if q_check || b_check
        if b_check
          flash[:warning] ="You have reached your maximum number of (#{$community_account.block_limit}) blocks."
        elsif q_check
          flash[:warning] = "You have reached your maximum number of (#{$community_account.question_limit}) questions."
        end
        respond_to do |format|
          format.html {redirect_to root_path}
          format.js{

            render :js => "window.location.href = '#{root_path}'" 
            return
          }
        end
      end
    end
  end
end
