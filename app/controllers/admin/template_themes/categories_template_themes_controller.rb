class Admin::TemplateThemes::CategoriesTemplateThemesController < AdminController
  prepend_before_action :set_template_theme
  before_action :set_admin_category_question, only: [:edit_question, :update_question]

  def new
    authorize nil, :is_admin?, policy_class: AdminPolicy

    respond_to do |format|
      format.js
    end

    find_block = CategoriesTemplateTheme.where(category_id: params[:category_id], template_theme_id: params[:template_theme_id] )

    if !find_block.present?

      master_category = Category.find(params[:category_id])
      cloned_category = master_category.deep_clone include: [:questions => :question_labels, questions:  [ :question_labels => :image_attachment]]

      cloned_category.title = master_category.title
      cloned_category.description = master_category.description

      cloned_category.account_id = $community_account.id
      cloned_category.cloned = true
      cloned_category.cloned_from = master_category.id

      cloned_category.position = master_category.position

      cloned_category.industry_ids = master_category.industry_ids

      cloned_category.save!

      category = Category.find(cloned_category.id).questions.pluck(:question_type).include?("Screener")
      position_no = category == true ? 0 :  CategoriesTemplateTheme.where(template_theme_id: params[:template_theme_id]).count + 1
      CategoriesTemplateTheme.create!(category_id: cloned_category.id, template_theme_id: params[:template_theme_id], position: position_no )
      if category
        CategoriesTemplateTheme.where(template_theme_id: params[:template_theme_id]).where.not(category_id: cloned_category.id).update_all(["position=position+1"])
      end
      # CategoriesTemplateTheme.find(params[:category][:position]).update(category_id: cloned_category.id)

    end
  end

  def destroy
    authorize nil, :is_admin?, policy_class: AdminPolicy

    respond_to do |format|
      format.js
    end

    find_block = CategoriesTemplateTheme.where(category_id: params[:category_id], template_theme_id: params[:template_theme_id] )

    if find_block.present?
      find_block.destroy_all
    end
  end

  def reset
    authorize nil, :is_admin?, policy_class: AdminPolicy

    find_block = CategoriesTemplateTheme.where(category_id: params[:category_id], template_theme_id: params[:template_theme_id] )

    if find_block.present?

      master_category = Category.find(params[:cloned_from])
      cloned_category = master_category.deep_clone include: [:questions => :question_labels, questions:  [ :question_labels => :image_attachment]]

      cloned_category.title = master_category.title
      cloned_category.description = master_category.description

      cloned_category.account_id = $community_account.id
      cloned_category.cloned = true
      cloned_category.cloned_from = master_category.id

      cloned_category.position = master_category.position

      cloned_category.industry_ids = master_category.industry_ids

      cloned_category.save!

      category = Category.find(cloned_category.id).questions.pluck(:question_type).include?("Screener")
      position_no = category == true ? 0 :  find_block.first.position
      CategoriesTemplateTheme.create!(category_id: cloned_category.id, template_theme_id: params[:template_theme_id], position: position_no )
      if category
        CategoriesTemplateTheme.where(template_theme_id: params[:template_theme_id]).where.not(category_id: cloned_category.id).update_all(["position=position+1"])
      end

      master_find_block = CategoriesTemplateTheme.where(category_id: cloned_category.id, template_theme_id: params[:template_theme_id] )

      if !master_find_block.present?
        CategoriesTemplateTheme.create!(category_id: cloned_category.id, template_theme_id: params[:template_theme_id], position: find_block.first.position )
      end

      find_block.destroy_all
    end

    respond_to do |format|
      format.js
    end
  end

  def get_group_by_question_types_templates
    if current_account.admin?
      label_templates = LabelTemplate.all.group_by(&:question_type)
    else
      label_templates = LabelTemplate.where(template_type: 0).group_by(&:question_type)
    end

    @question = Question.find_by_id(params[:id])
    @options = label_templates[@question.present? ? @question.question_type : params[:question_type]]

    respond_to do |format|
      format.js
    end
  end

  def add_block_modal
    authorize nil, :is_admin?, policy_class: AdminPolicy
    categories = if @template.industries.present?
                   if @template.industries.count == Industry.count
                     Category.all
                   else
                     # Category.where(id: @template.industries.map{|c| c.category_ids}.flatten.uniq)
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
    @custom_categories = @categories.where(account_id: $community_account.id, saved_block: false, survey_id: nil, block_relation_type: nil, cloned: true).reorder(Arel.sql("LENGTH(title) desc"))
    total_limit = (@custom_categories.size / 2.to_f).ceil
    # @left_custom_categories = @custom_categories.limit(total_limit)
    @left_custom_categories = []
    # @right_custom_categories = @custom_categories.offset(total_limit)
    @right_custom_categories = []
    respond_to do |format|
      format.js
    end
  end

  def clone_block_modal
    authorize nil, :is_admin?, policy_class: AdminPolicy

    respond_to do |format|
      format.js
    end
  end

  def clone_block
    authorize nil, :is_admin?, policy_class: AdminPolicy

    master_category = Category.find(params[:category][:category_id])
    cloned_category = master_category.deep_clone include: [:questions => :question_labels, questions:  [ :question_labels => :image_attachment]]

    cloned_category.title = params[:category][:title]
    cloned_category.description = params[:category][:description]

    cloned_category.account_id = $community_account.id
    cloned_category.cloned = true
    cloned_category.cloned_from = master_category.id

    cloned_category.position = Category.all.count

    cloned_category.industry_ids = master_category.industry_ids

    cloned_category.save!

    CategoriesTemplateTheme.find(params[:category][:position]).update(category_id: cloned_category.id)

    respond_to do |format|
      format.js
    end
  end

  def edit_block_modal
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @category = Category.find(params[:category_id])

    respond_to do |format|
      format.js
    end
  end

  def edit_block
    authorize nil, :is_admin?, policy_class: AdminPolicy

    master_category = Category.find(params[:category][:category_id])

    master_category.title = params[:category][:title]
    master_category.description = params[:category][:description]

    master_category.save!

    respond_to do |format|
      format.js
    end
  end

  def edit_question
    authorize nil, :is_admin?, policy_class: AdminPolicy

    respond_to do |format|
      format.js
    end
  end

  def delete_question
    authorize nil, :is_admin?, policy_class: AdminPolicy

    Question.find_by_id(params[:question_id]).destroy

    respond_to do |format|
      format.js
    end
  end


  def update_question
    authorize nil, :is_admin?, policy_class: AdminPolicy

    label_template_id = if params[:question][:label_template_id].present?
                          if params[:question][:label_template_id] == 'Custom'
                            template = LabelTemplate.find_or_create_by(title: 'Custom', description: '', default_type: 'system-custom', slug_id: 'system-custom1')
                            template.id
                          elsif params[:question][:label_template_id] == 'Custom with scores'
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

    @admin_category_question.update(admin_category_question_params.merge(label_template_id: label_template_id))

    respond_to do |format|
      format.js
    end
  end

  private

  def set_template_theme
    @template = TemplateTheme.find(params[:template_theme_id])

    categories = if @template.industries.present?
                   if @template.industries.count == Industry.count
                     Category.all
                   else
                     Category.find(@template.industries.map{|c| c.category_ids}.flatten.uniq)
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
    params.require(:question).permit(:title, :description, :question_type, :required, :chart_type, :category_id, :other_specify, :geographic_type,
                                     :other_label_min_length, :other_label_max_length, :position, :label_template_id, data_json: {},
                                     question_labels_attributes: [:id, :label, :score, :tag, :show_label, :show_tag, :position, :category_id, :_destroy, :image, :correct_answer, :branch_to])
  end

end
