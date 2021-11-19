class Surveys::CategoriesSurveysController < ApplicationController
  prepend_before_action :set_survey
  before_action :set_admin_category_question, only: [:edit_question, :update_question, :duplicate_question]

  def new
    authorize nil, :is_account?, policy_class: AccountPolicy

    if !@locked
      find_block = CategoriesSurvey.where(category_id: params[:category_id], survey_id: params[:survey_id])

      if !find_block.present?

        master_category = Category.find(params[:category_id])

        if ($community_account.question_limit < (Question.where(category_id: @survey.categories_surveys.pluck(:category_id)).to_a.size + master_category.questions.to_a.size))
          flash[:warning] = "You have reached your maximum number of (#{$community_account.question_limit}) questions."
          respond_to do |format|
            format.html { redirect_to survey_step_path(@survey, 'build') }
            format.js {

              render :js => "window.location.href = '#{survey_step_path(@survey, 'build')}'"
              return
            }
          end
        end
        cloned_category = master_category.deep_clone include: [:questions => :question_labels, questions: [:question_labels => :image_attachment]]

        cloned_category.account_id = $community_account.id
        cloned_category.cloned = false
        cloned_category.cloned_from = nil
        cloned_category.master_id = master_category.id
        # cloned_category.saved_block = false

        cloned_category.survey_id = params[:survey_id]
        cloned_category.industry_ids = master_category.industry_ids

        cloned_category.save!
        categories_survey_create = CategoriesSurvey.new
        categories_survey_create.survey_id = params[:survey_id]
        categories_survey_create.category_id = cloned_category.id
        if cloned_category.questions.pluck(:question_type).include?("Screener")
          CategoriesSurvey.where(survey_id: params[:survey_id]).where.not(category_id: cloned_category.id).update_all(["position=position+1"])
          categories_survey_create.position = 0
        else
          cat_survey = CategoriesSurvey.where(survey_id: params[:survey_id])
          categories_survey_create.position = cat_survey && cat_survey.last && cat_survey.last.position ? cat_survey.last.position + 1 : 1
        end
        categories_survey_create.save
        if cloned_category.questions.pluck(:sort_results).any?(true) || cloned_category.questions.pluck(:is_branching).any?(true) || cloned_category.questions.first.question_type == Question.question_types.key(14)
          @sort_question = @survey.categories_surveys.includes(category: [:questions]).collect { |c| c.category.questions.find_by(sort_results: true) }.reject(&:blank?).take(1)
          if @sort_question.present?
            @sort_question.first.update_column(:sort_results, false)
          end
        end

      end
    end

    respond_to do |format|
      format.js
    end

  end

  def destroy
    authorize nil, :is_account?, policy_class: AccountPolicy

    respond_to do |format|
      format.js
    end

    @accordion_remove = params[:remove_block] ? true : false

    if !@locked
      find_block = Category.where(id: params[:category_id], survey_id: params[:survey_id])

      if find_block.present?
        QuestionLabel.where(branch_to: params[:category_id]).update_all(branch_to: 0) rescue nil
        find_block.destroy_all
      end
    end
  end

  def reset
    authorize nil, :is_account?, policy_class: AccountPolicy

    begin

      cat = Category.find(params[:category_id])

      if cat.cloned? and !@locked
        find_block = CategoriesSurvey.where(category_id: params[:category_id], survey_id: params[:survey_id])

        if find_block.present?

          master_find_block = CategoriesSurvey.where(category_id: params[:master_id], survey_id: params[:survey_id])

          if !master_find_block.present?

            master_category = Category.find_by_id(params[:master_id])
            cloned_category = master_category.deep_clone include: [:questions => :question_labels, questions: [:question_labels => :image_attachment]]

            cloned_category.account_id = $community_account.id
            cloned_category.cloned = false
            cloned_category.cloned_from = nil
            # cloned_category.saved_block = false

            cloned_category.survey_id = params[:survey_id]
            cloned_category.master_id = master_category.id
            cloned_category.industry_ids = master_category.industry_ids

            cloned_category.save!

            CategoriesSurvey.create!(survey_id: params[:survey_id], category_id: cloned_category.id, position: find_block.first.position)

            if master_category.account_id == $community_account.id and master_category.saved_block == false
              master_category.destroy
            end

          end
          if find_block.present?
            QuestionLabel.where(branch_to: params[:category_id]).update_all(branch_to: 0) rescue nil
            find_block.destroy_all
            cat.destroy
          end
        end

        flash.now[:success] = 'Item was reset successfully'

      else

        flash.now[:error] = 'You are not authorized to perform this action'

      end


    rescue

      flash.now[:warning] = 'You can not reset this block anymore because you deleted its parent block.'

    end

    respond_to do |format|
      format.js
    end
  end

  def get_group_by_question_types_templates
    authorize nil, :is_account?, policy_class: AccountPolicy

    if current_account.admin?
      label_templates = LabelTemplate.all.group_by(&:question_type)
    else
      label_templates = LabelTemplate.where(template_type: 0).group_by(&:question_type)
    end

    if params[:sus]
      @cate = Category.find(params[:sus])
    end

    @question = Question.find_by_id(params[:id])
    @options = label_templates[@question.present? ? @question.question_type : params[:question_type]]

    respond_to do |format|
      format.js
    end
  end

  def new_recipient_modal
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @list = List.find(params[:list_id])
    @recipient = Recipient.new

    respond_to do |format|
      format.js
    end
  end

  def create_recipient
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @list = List.find(params[:list_id])
    @survey = Survey.find(params[:survey_id])

    recipients_ids = []

    if params[:recipient][:single_email].present?

      recipient = Recipient.find_or_create_by(account_id: $community_account.id, email: params[:recipient][:single_email], created_by_id: current_account.id)
      ListsRecipient.find_or_create_by(recipient_id: recipient.id, list_id: params[:list_id])

      recipients_ids.push(recipient.id)
    elsif params[:recipient][:multi_emails].present?

      params[:recipient][:multi_emails].split(",").each do |recipient|
        recipient = Recipient.find_or_create_by(account_id: $community_account.id, email: recipient.strip, created_by_id: current_account.id)
        ListsRecipient.find_or_create_by(recipient_id: recipient.id, list_id: params[:list_id])
        recipients_ids.push(recipient.id)
      end

    end

    @recipients = Recipient.find(recipients_ids)

    if @locked
      @recipients.each do |recipient|

        @survey.recipients_surveys.find_or_create_by(recipient_id: recipient.id, allow_survey: "true", list_id: @list.id)

        AccountMailer.send_submission_links(params[:locale], recipient, @survey).deliver_later

      end
    end

    respond_to do |format|
      format.js
    end
  end

  def new_list_modal
    authorize nil, :is_account?, policy_class: AccountPolicy

    @list = List.new

    respond_to do |format|
      format.js
    end
  end

  def create_list
    authorize nil, :is_account?, policy_class: AccountPolicy

    @list = List.new(list_params)
    @list.account_id = $community_account.id
    @list.created_by_id = current_account.id

    if @list.save
      params[:list][:multi_emails].split(",").each do |recipient|
        recipient = Recipient.find_or_create_by(account_id: $community_account.id, email: recipient, created_by_id: current_account.id)
        ListsRecipient.find_or_create_by(recipient_id: recipient.id, list_id: @list.id)
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def remove_custom_block
    authorize nil, :is_account?, policy_class: AccountPolicy

    @category = Category.find(params[:category_id])

    if @category.account_id == $community_account.id
      @category.destroy

      respond_to do |format|
        format.js
      end
    end
  end

  def add_block_modal
    authorize nil, :is_account?, policy_class: AccountPolicy

    if $community_account.block_limit <= @survey.categories_surveys.to_a.size
      flash[:warning] = "You have reached your maximum number of (#{$community_account.block_limit}) blocks."
      respond_to do |format|
        format.html { redirect_to survey_step_path(@survey, 'build') }
        format.js {

          render :js => "window.location.href = '#{survey_step_path(@survey, 'build')}'"
          return
        }
      end
    end

    categories = if @survey.industries.present?
                   if @survey.industries.count == Industry.count
                     Category.all
                   else
                     # Category.find(@survey.industries.map{|c| c.category_ids}.flatten.uniq)
                     # Category.where(id: @survey.industries.map{|c| c.category_ids}.flatten.uniq)
                     Category.all
                   end
                 else
                   Category.all
                 end
    @categories = categories
    @default_categories = @categories.where(cloned_from: nil, saved_block: false, survey_id: nil, block_relation_type: nil).reorder(Arel.sql("LENGTH(title) desc"))
    d_total_limit = (@default_categories.size / 2.to_f).ceil
    @left_default_categories = @default_categories.limit(d_total_limit)
    @right_default_categories = @default_categories.offset(d_total_limit)
    @custom_categories = @categories.where(account_id: $community_account.id, saved_block: true, survey_id: nil, block_relation_type: nil).reorder(Arel.sql("LENGTH(title) desc"))
    total_limit = (@custom_categories.size / 2.to_f).ceil
    @left_custom_categories = @custom_categories.limit(total_limit)
    @right_custom_categories = @custom_categories.offset(total_limit)
    respond_to do |format|
      format.js
    end
  end

  def clone_block_modal
    authorize nil, :is_account?, policy_class: AccountPolicy

    respond_to do |format|
      format.js
    end
  end

  def clone_block
    authorize nil, :is_account?, policy_class: AccountPolicy

    if !@locked
      master_category = Category.find(params[:category][:category_id])
      cloned_category = master_category.deep_clone include: [:questions => :question_labels, questions: [:question_labels => :image_attachment]]

      cloned_category.title = params[:category][:title]
      cloned_category.description = params[:category][:description]

      cloned_category.account_id = $community_account.id
      cloned_category.cloned = true
      cloned_category.cloned_from = master_category.id

      cloned_category.position = Category.all.count

      cloned_category.industry_ids = master_category.industry_ids

      cloned_category.save!

      CategoriesSurvey.find(params[:category][:position]).update(category_id: cloned_category.id)
    end

    respond_to do |format|
      format.js
    end
  end

  def edit_block_modal
    authorize nil, :is_account?, policy_class: AccountPolicy

    @category = Category.find(params[:category_id])

    respond_to do |format|
      format.js
    end
  end

  def edit_block
    authorize nil, :is_account?, policy_class: AccountPolicy

    @category = Category.find(params[:category][:category_id])

    if @category.survey_id == @survey.id

      @category.title = params[:category][:title]
      @category.description = params[:category][:description]
      @category.cloned = true

      @category.save!

    end

    respond_to do |format|
      format.js
    end
  end

  def edit_question
    authorize nil, :is_account?, policy_class: AccountPolicy
    set_sort_enable
    @sort_question_record = @survey.categories_surveys.includes(category: [:questions]).collect { |c| c.category.questions.find_by(sort_results: true) }.reject(&:blank?).take(1).first rescue nil
    @sort_question = @sort_question_record.sort_results rescue nil
    @sort_question_title = @sort_question_record.present? ? @sort_question_record.title : "#{t 'surveys.none'}" rescue nil
    @recipients_results = @survey.submissions.present? ? @survey.aggregator.result["recipients"][@admin_category_question.category.id.to_s][@admin_category_question.id.to_s].freeze : nil
    @all_answered = @survey.submissions.present? ? @survey.submissions.to_a.size == @recipients_results.map { |a| a[1].values.flatten.blank? }.count(false) : true
    respond_to do |format|
      format.js
    end
  end

  def update_question
    authorize nil, :is_account?, policy_class: AccountPolicy

    @category = @admin_category_question.category

    if @category.survey_id == @survey.id
      label_template_id = if params[:question][:label_template_id].present?
                            if params[:question][:label_template_id] == "#{t 'surveys.custom'}"
                              template = LabelTemplate.find_or_create_by(title: 'Custom', description: '', default_type: 'system-custom', slug_id: 'system-custom1')
                              template.id
                            elsif params[:question][:label_template_id] == "#{t 'surveys.custom_with_scores'}"
                              template = LabelTemplate.find_or_create_by(title: 'Custom with scores', description: '', default_type: 'system-custom', slug_id: 'system-custom2')
                              template.id
                            elsif params[:question][:label_template_id] == 'Single Select'
                              template = LabelTemplate.find_or_create_by!(title: 'Single Select', description: '', default_type: 'system-custom', slug_id: 'system-custom3')
                              template.id
                            elsif params[:question][:label_template_id] == 'Multiple Select'
                              template = LabelTemplate.find_or_create_by!(title: 'Multiple Select', description: '', default_type: 'system-custom', slug_id: 'system-custom4')
                              template.id
                            else
                              params[:question][:label_template_id]
                            end
                          elsif @admin_category_question.is_branching?
                            template = LabelTemplate.find_or_create_by!(title: 'Single Select', description: '', default_type: 'system-custom', slug_id: 'system-custom3')
                            template.id
                          else
                            0
                          end
      if params[:question][:sort_results] == "1"
        if @admin_category_question.check_question_type_for_sort @locked, params
          @sort_question = @survey.categories_surveys.includes(category: [:questions]).collect { |c| c.category.questions.find_by(sort_results: true) }.reject(&:blank?).take(1)
          if @sort_question.present?
            unless @sort_question.first.id == @admin_category_question.id
              @sort_question.first.update_column(:sort_results, false)
            else
              params[:question][:required] = '1'
            end
          end
          params[:question][:required] = '1'
        else
          params[:question][:sort_results] = '0'
        end
      end
      if label_template_id != 0
        @admin_category_question.update(admin_category_question_params.merge(label_template_id: label_template_id))
      else
        @admin_category_question.update(admin_category_question_params)
      end
      @admin_category_question.category.update(cloned: true)
      if params[:question][:question_type].present?
        unless params[:question][:question_type] == Question.question_types.key(0) || params[:question][:question_type] == Question.question_types.key(4) || params[:question][:question_type] == Question.question_types.key(13)
          @admin_category_question.update(other_specify: 1)
        end
      end

    end

    respond_to do |format|
      format.js
    end
  end

  def new_question
    authorize nil, :is_account?, policy_class: AccountPolicy

    if $community_account.question_limit <= @survey.categories_surveys.collect { |c| c.category.questions.to_a.size }.sum
      flash[:warning] = "You have reached your maximum number of (#{$community_account.question_limit}) questions."
      respond_to do |format|
        format.html { redirect_to survey_step_path(@survey, 'build') }
        format.js {

          render :js => "window.location.href = '#{survey_step_path(@survey, 'build')}'"
          return
        }
      end
    end

    if !@locked
      @admin_category_question = Question.new
      1.times { @admin_category_question.question_labels.build }
    end
    set_sort_enable
    @sort_question_record = @survey.categories_surveys.includes(category: [:questions]).collect { |c| c.category.questions.find_by(sort_results: true) }.reject(&:blank?).take(1).first rescue nil
    @sort_question = @sort_question_record.sort_results rescue nil
    @sort_question_title = @sort_question_record.present? ? @sort_question_record.title : "#{t 'surveys.none'}" rescue nil
    respond_to do |format|
      format.js
    end
  end

  def new_question_submit
    authorize nil, :is_account?, policy_class: AccountPolicy

    if !@locked

      @category = Category.find(params[:question][:category_id])

      if @category.survey_id == @survey.id
        label_template_id = if params[:question][:label_template_id].present?
                              if params[:question][:label_template_id] == "#{t 'surveys.custom'}"
                                template = LabelTemplate.find_or_create_by(title: 'Custom', description: '', default_type: 'system-custom', slug_id: 'system-custom1')
                                template.id
                              elsif params[:question][:label_template_id] == "#{t 'surveys.custom_with_scores'}"
                                template = LabelTemplate.find_or_create_by(title: 'Custom with scores', description: '', default_type: 'system-custom', slug_id: 'system-custom2')
                                template.id
                              elsif params[:question][:label_template_id] == 'Single Select'
                                template = LabelTemplate.find_or_create_by!(title: 'Single Select', description: '', default_type: 'system-custom', slug_id: 'system-custom3')
                                template.id
                              elsif params[:question][:label_template_id] == 'Multiple Select'
                                template = LabelTemplate.find_or_create_by!(title: 'Multiple Select', description: '', default_type: 'system-custom', slug_id: 'system-custom4')
                                template.id
                              else
                                params[:question][:label_template_id]
                              end
                            else
                              0
                            end
        @admin_category_question = Question.new(admin_category_question_params.merge(label_template_id: label_template_id))
        @admin_category_question.position = @admin_category_question.category.questions.count + 1
        @admin_category_question.category.update(cloned: true)
        if params[:question][:sort_results] == "1"
          @sort_question = @survey.categories_surveys.includes(category: [:questions]).collect { |c| c.category.questions.find_by(sort_results: true) }.reject(&:blank?).take(1)
          if @sort_question.present?
            unless @sort_question.first.id == @admin_category_question.id
              @sort_question.first.update_column(:sort_results, false)
            else
              params[:question][:required] = '1'
            end
          end
          params[:question][:required] = '1'
        end

        @admin_category_question.save!

      end


      # master_category = Category.find(params[:question][:category_id])
      # saved_block_category = Category.where(master_id: params[:question][:category_id], saved_block: true).last rescue nil 
      # unless saved_block_category.nil?
      #   saved_block_category.destroy
      # end
      #   cloned_category = master_category.deep_clone include: [:questions => :question_labels]

      #   cloned_category.title = master_category.title
      #   cloned_category.description = master_category.description

      #   cloned_category.account_id = $community_account.id
      #   cloned_category.cloned = false
      #   cloned_category.cloned_from = nil

      #   cloned_category.survey_id = nil
      #   cloned_category.saved_block = true
      #   cloned_category.block_relation_type = nil
      #   cloned_category.master_id = master_category.id
      #   cloned_category.industry_ids = master_category.industry_ids

      #   cloned_category.save!


      respond_to do |format|
        format.js
      end

    end
  end

  def duplicate_question
    authorize nil, :is_account?, policy_class: AccountPolicy

    if $community_account.question_limit <= @survey.categories_surveys.collect { |c| c.category.questions.to_a.size }.sum
      flash[:warning] = "You have reached your maximum number of (#{$community_account.question_limit}) questions."
      respond_to do |format|
        format.html { redirect_to survey_step_path(@survey, 'build') }
        format.js {

          render :js => "window.location.href = '#{survey_step_path(@survey, 'build')}'"
          return
        }
      end
    end

    if !@locked
      duplicate_question = @admin_category_question.deep_clone include: [:question_labels, question_labels: [:image_attachment]]
      @category = duplicate_question.category

      if @category.survey_id == @survey.id
        duplicate_question.title = duplicate_question.title + " (#{@category.questions.where("title LIKE :query", query: "%#{duplicate_question.title}%").count})"
        duplicate_question.position = @category.questions.count + 1
        if duplicate_question.save!
          if duplicate_question.sort_results?
            @sort_question = @survey.categories_surveys.includes(category: [:questions]).collect { |c| c.category.questions.find_by(sort_results: true) }.reject(&:blank?).take(1)
            if @sort_question.present?
              @sort_question.first.update_column(:sort_results, false)
            end
          end
          @category.update(cloned: true)

          flash.now[:success] = 'Item was duplicated successfully'
        else
          flash.now[:error] = 'Something went wrong please try again'
        end

      end

    end

    respond_to do |format|
      format.js
    end
  end

  def delete_question
    authorize nil, :is_account?, policy_class: AccountPolicy

    if !@locked_build_mode
      question = Question.find_by_id(params[:question_id])
      @category = question.category

      if @category.survey_id == @survey.id

        question.category.update(cloned: true)
        question.destroy

      end

      respond_to do |format|
        format.js
      end
    end
  end

  def save_as_block_modal
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @category = Category.find(params[:category_id])

    respond_to do |format|
      format.js
    end
  end

  def save_as_block_submit
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    begin

      master_category = Category.find(params[:category][:category_id])
      cloned_category = master_category.deep_clone include: [:questions => :question_labels, questions: [:question_labels => :image_attachment]]

      cloned_category.title = params[:category][:title]
      cloned_category.description = params[:category][:description]

      cloned_category.account_id = $community_account.id
      cloned_category.cloned = false
      cloned_category.cloned_from = nil

      cloned_category.survey_id = nil
      cloned_category.saved_block = true
      cloned_category.block_relation_type = nil
      cloned_category.master_id = master_category.id
      cloned_category.industry_ids = master_category.industry_ids

      cloned_category.save!
      q_labels = cloned_category.questions.first.is_branching? ? cloned_category.questions.first.question_labels.update_all(branch_to: 0) : "" rescue nil

      flash.now[:success] = 'Item was saved successfully '

    rescue

      flash.now[:error] = 'Something went wrong please try again.'

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

    @locked = if Survey.survey_states.key(1) == @survey.survey_state
                true
              else
                false
              end

    @locked_build_mode = if Survey.survey_states.key(1) == @survey.survey_state and @survey.submissions.present?
                           true
                         else
                           false
                         end

    categories = if @survey.industries.present?
                   if @survey.industries.count == Industry.count
                     Category.all
                   else
                     Category.find(@survey.industries.map { |c| c.category_ids }.flatten.uniq)
                   end
                 else
                   Category.all
                 end
    @categories = categories
  end

  def set_admin_category_question
    @admin_category_question = Question.find(params[:question_id])
  end

  def admin_category_question_params
    params.require(:question).permit(:title, :description, :question_type, :required, :sort_results, :chart_type, :category_id, :other_specify, :geographic_type,
                                     :other_label_min_length, :other_label_max_length, :position, :label_template_id, data_json: {},
                                     question_labels_attributes: [:id, :label, :score, :tag, :show_label, :show_tag, :position, :category_id, :_destroy, :image, :correct_answer, :branch_to])
  end

  def list_params
    params.require(:list).permit(:title, :account_id, :created_by_id)
  end

  def set_sort_enable
    categories_surveyss = @survey.categories_surveys.includes(category: [:questions])
    sort_branching = categories_surveyss.collect { |c| c.category.questions.find_by(is_branching: true) }.reject(&:blank?).take(1).first rescue nil
    sort_screener = categories_surveyss.collect { |c| c.category.questions.find_by(question_type: 14) }.reject(&:blank?).take(1).first rescue nil
    @sort_enable = (sort_branching.present? || sort_screener.present?) ? false : true
  end

end
