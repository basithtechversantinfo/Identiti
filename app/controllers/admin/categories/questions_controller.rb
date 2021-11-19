class Admin::Categories::QuestionsController < AdminController
  before_action :set_admin_category_question, only: [:show, :edit, :update, :destroy]
  append_before_action :set_admin_category, only: [:new, :edit, :show, :create, :update, :destroy]

  def index
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @admin_category_questions = Question.where(category_id: params[:category_id])
  end

  def show
    authorize nil, :is_admin?, policy_class: AdminPolicy

    respond_to do |format|
      format.js
    end
  end

  def new
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @admin_category_question = Question.new
    1.times { @admin_category_question.question_labels.build }
    respond_to do |format|
      format.js
    end
  end

  def edit
    authorize nil, :is_admin?, policy_class: AdminPolicy

    respond_to do |format|
      format.js
    end
  end

  def create
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

    @admin_category_question = Question.new(admin_category_question_params.merge(label_template_id: label_template_id))
    @admin_category_question.position = @admin_category_question.category.questions.count + 1

    @admin_category_question.save!

    if @admin_category_question.is_branching?
      @admin_category_question.category.update(is_branching: 1)
    end

    if @admin_category_question.question_type == "Screener"
      unless @admin_category_question.category.position == 0
        Category.where(account_id: $community_account.id).where.not(id: @admin_category_question.category.id).update_all(["position=position+1"])

        @admin_category_question.category.update(position: 0)
      end
    end

    respond_to do |format|
      format.js
    end
  end

  def update
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

  def destroy
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @admin_category_question.destroy

    respond_to do |format|
      format.js
    end
  end

  private
  def set_admin_category_question
    @admin_category_question = Question.find(params[:id])
  end

  def set_admin_category
    @admin_category = Category.find(params[:category_id])
  end

  def admin_category_question_params
    params.require(:question).permit(:title, :description, :question_type, :required, :chart_type, :category_id, :label_template_id, :other_specify, :geographic_type,
                                     :other_label_min_length, :other_label_max_length, :position, :is_branching, data_json: {},
                                     question_labels_attributes: [:id, :label, :score, :tag, :show_label, :show_tag, :position, :category_id, :_destroy, :image, :correct_answer, :branch_to])
  end
end
