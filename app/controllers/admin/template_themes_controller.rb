class Admin::TemplateThemesController < AdminController
  layout "survey_build", only: [:new, :edit]
  before_action :set_template_theme, only: [:show, :edit, :update, :destroy, :preview, :clone_template_modal, :clone_template]

  def index
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @template_themes = TemplateTheme.where(account_id: $community_account.id).order(title: :asc)
  end

  def show
    authorize nil, :is_admin?, policy_class: AdminPolicy

    redirect_to admin_template_theme_step_path(@template_theme, 'setup')
  end

  def new
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @template_theme = TemplateTheme.new
  end

  def edit
    authorize nil, :is_admin?, policy_class: AdminPolicy

    redirect_to admin_template_theme_step_path(@template_theme, 'setup')
  end

  def create
    authorize nil, :is_admin?, policy_class: AdminPolicy

    @template_theme = TemplateTheme.new(template_theme_params)
    @template_theme.account_id = $community_account.id
    @template_theme.default_template = true

    respond_to do |format|
      if @template_theme.save
        format.html { redirect_to admin_template_theme_step_path(@template_theme, 'build') }
        format.json { render :show, status: :created, location: admin_template_theme_path(@template_theme) }
      else
        format.html { render :new }
        format.json { render json: @template_theme.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize nil, :is_admin?, policy_class: AdminPolicy

    if params[:template_type]
      respond_to do |format|
        if @template_theme.update_attributes(template_type: params[:template_type])
          format.html { redirect_to admin_template_theme_path(@template_theme) }
          format.json { render :show, status: :ok, location: admin_template_theme_path(@template_theme) }
        else
          format.html { render :edit }
          format.json { render json: @template_theme.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        if @template_theme.update(template_theme_params)
          format.html { redirect_to admin_template_theme_path(@template_theme) }
          format.json { render :show, status: :ok, location: admin_template_theme_path(@template_theme) }
        else
          format.html { render :edit }
          format.json { render json: @template_theme.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    authorize nil, :is_admin?, policy_class: AdminPolicy

    respond_to do |format|
      if @template_theme.destroy
        format.html { redirect_to admin_template_themes_url
        # , notice: 'Survey theme was successfully destroyed.'
        }
      else
        format.html { redirect_to admin_template_themes_url, notice: @template_theme.errors.full_messages.to_sentence }
      end
    end
  end

  def preview
    respond_to do |format|
      format.js
    end
  end

  def clone_template_modal
    authorize nil, :is_admin?, policy_class: AdminPolicy
    
    respond_to do |format|
      format.js
    end
  end

  def clone_template
    authorize nil, :is_admin?, policy_class: AdminPolicy

    master_category = @template_theme
    cloned_category = master_category.deep_clone include: [:industries => :industries_template_themes, :categories => :categories_industries]
    cloned_category.title = params[:template_theme][:title]
    cloned_category.account_id = $community_account.id
    cloned_category.industry_ids = params[:template_theme][:industry_ids]
    
    respond_to do |format|
      if cloned_category.save!
        format.html { redirect_to admin_template_themes_url }
      else
        format.html { redirect_to admin_template_themes_url, notice: cloned_category.errors.full_messages.to_sentence }
      end
    end
  end

  private
    def set_template_theme
      @template_theme = TemplateTheme.find(params[:id])
    end

    def template_theme_params
      params.require(:template_theme).permit(:title, :account_id, :default_template, industry_ids: [])
    end
end
