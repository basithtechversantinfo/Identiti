class Admin::CategoriesController < ApplicationController
  before_action :set_admin_category, only: [:show, :edit, :update, :destroy, :preview]

  def index
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @admin_categories = Category.where(account_id: $community_account.id).where(cloned: false, survey_id: nil)
  end

  def show
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @admin_category_questions = @admin_category.questions
    respond_to do |format|
      if @admin_category_questions
        format.html
        format.js
      end
    end
  end

  def new
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @admin_category = Category.new
  end

  def edit
    authorize nil, :is_admin?, policy_class: AdminPolicy
  end

  def create
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @admin_category = Category.new(admin_category_params)
    @admin_category.position = Category.where(account_id: $community_account.id).last.position + 1
    @admin_category.account_id = $community_account.id

    respond_to do |format|
      if @admin_category.save
        format.html { redirect_to admin_category_path(@admin_category)
        # , notice: 'Block was successfully created.'
        }
      else
        format.html { render :new }
      end
    end
  end

  def update
    authorize nil, :is_admin?, policy_class: AdminPolicy

    respond_to do |format|
      if @admin_category.update(admin_category_params)
        cloned_categories = Category.where(master_id: @admin_category.id)
        cloned_categories.update_all(description: admin_category_params[:description]) unless cloned_categories.blank?
        format.html { redirect_to admin_category_path(@admin_category)
        # , notice: 'Block was successfully updated.'
        }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    authorize nil, :is_admin?, policy_class: AdminPolicy

    respond_to do |format|
      if @admin_category.destroy
        format.html { redirect_to admin_categories_url
        # , notice: 'Block was successfully deleted.'
        }
      else
        format.html { redirect_to admin_categories_url, notice: @admin_category.errors.full_messages.to_sentence }
      end
    end
  end

  def preview
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
    cloned_category.cloned = false
    cloned_category.cloned_from = nil
    cloned_category.template_theme_ids = []

    cloned_category.position = master_category.position

    cloned_category.industry_ids = master_category.industry_ids

    cloned_category.save!

    redirect_to admin_category_path(cloned_category)
  end

  private
  def set_admin_category
    @admin_category = Category.find(params[:id])
  end

  def admin_category_params
    params.require(:category).permit(:title, :description, :position, :account_id, :display_type, :block_button_color,
                                     industry_ids: [])
  end
end
