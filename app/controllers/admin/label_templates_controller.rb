class Admin::LabelTemplatesController < ApplicationController
  before_action :set_admin_label_template, only: [:show, :edit, :update, :destroy]

  def index
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @admin_label_templates = LabelTemplate.user_default_type
  end

  def show
    authorize nil, :is_admin?, policy_class: AdminPolicy
  end

  def new
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @admin_label_template = LabelTemplate.new
    1.times { @admin_label_template.question_labels.build }

  end

  def edit
    authorize nil, :is_admin?, policy_class: AdminPolicy
  end

  def create
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @admin_label_template = LabelTemplate.new(label_template_params)
    @admin_label_template.account_id = $community_account.id

    respond_to do |format|
      if @admin_label_template.save
        format.html { redirect_to admin_label_templates_path
        # , notice: 'Question type template was successfully created.'
        }
        format.json { render :show, status: :created, location: @admin_label_template }
      else
        format.html { render :new }
        format.json { render json: @admin_label_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize nil, :is_admin?, policy_class: AdminPolicy

    respond_to do |format|
      if @admin_label_template.update!(label_template_params)
        format.html { redirect_to admin_label_templates_path
        # , notice: 'Question type template was successfully updated.'
        }
        format.json { render :show, status: :ok, location: @admin_label_template }
      else
        format.html { render :edit }
        format.json { render json: @admin_label_template.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @admin_label_template.destroy
    respond_to do |format|
      format.html { redirect_to admin_label_templates_url
      # , notice: 'Question type template was successfully deleted.'
      }
      format.json { head :no_content }
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

  def get_template_description
    admin_label_template = LabelTemplate.find_by_id(params[:id])

    if admin_label_template.present?
     @result = admin_label_template.description
    else
      @result = ""
    end

    respond_to do |format|
      format.js
    end
  end

  private
  def set_admin_label_template
    @admin_label_template = LabelTemplate.find(params[:id])
  end

  def label_template_params
    params.require(:label_template).permit(:title, :description, :account_id, :question_type, :template_type,
                                           question_labels_attributes: [:id, :label, :score, :tag, :show_label, :show_tag, :position, :category_id, :_destroy])

  end
end
