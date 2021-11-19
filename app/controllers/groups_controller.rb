class GroupsController < ApplicationController
  layout 'frontend'
  before_action :set_group, only: [:edit, :update, :destroy]

  def choose_template
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy
    session[:survey_type] = params[:type] #Session finding the current survey type in entire application.
    check_limitation
    if params[:type].present? and params[:type].to_s == "persona"
      @template_type = 2
    else
      @template_type = 1
    end
    @industries_count_by_template_themes = Industry.all.group_by{ |c| c.template_themes.where(default_template: true).where("template_type LIKE ?", "%#{@template_type}%").count }.sort {|x,y| -(x <=> y)}
    @themes = @industries_count_by_template_themes.present? ? @industries_count_by_template_themes.first[1].first.template_themes.where(default_template: true).where("template_type LIKE ?", "%#{@template_type}%").order(title: :asc) : []
    
    respond_to do |format|
      format.js
    end
  end

  def choose_template_tab
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    if params[:type] == 'account'
      @industries_count_by_template_themes = Industry.all.group_by{ |c| c.template_themes.where(account_id: $community_account.id).count }.sort {|x,y| -(x <=> y)}
      @themes = @industries_count_by_template_themes.present? ? @industries_count_by_template_themes.first[1].first.template_themes.where(account_id: $community_account.id).order(title: :asc) : []
    else
      if params[:survey_type].present? and params[:survey_type].to_s == "persona"
        @template_type = 2
      else
        @template_type = 1
      end
      @industries_count_by_template_themes = Industry.all.group_by{ |c| c.template_themes.where(default_template: true).where("template_type LIKE ?", "%#{@template_type}%").count }.sort {|x,y| -(x <=> y)}
      @themes = @industries_count_by_template_themes.present? ? @industries_count_by_template_themes.first[1].first.template_themes.where(default_template: true).where("template_type LIKE ?", "%#{@template_type}%").order(title: :asc) : []
    end

    respond_to do |format|
      format.js
    end
  end

  def template_tab
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    check_limitation
    @industries_count_by_template_themes = Industry.all.group_by{ |c| c.template_themes.where(default_template: true).count }.sort {|x,y| -(x <=> y)}
    @themes = @industries_count_by_template_themes.present? ? @industries_count_by_template_themes.first[1].first.template_themes.where(default_template: true).order(title: :asc) : []
    
    
  end

  def industry_themes
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @industry = Industry.find_by_id(params[:id])

    if params[:type] == 'account'
      @themes = @industry.present? ? @industry.template_themes.where(account_id: $community_account.id).order(title: :asc) : []
    else
      if params[:type].present? and params[:type].to_s == "persona"
        @template_type = 2
      else
        @template_type = 1
      end
      @themes = @industry.present? ? @industry.template_themes.where("template_type LIKE ?", "%#{@template_type}%").order(title: :asc) : []
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy_template
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @template_theme = TemplateTheme.find(params[:id])

    if @template_theme.account_id == $community_account.id

      Category.where(id: @template_theme.categories_template_themes.pluck(:category_id)).destroy_all
      @template_theme.destroy

      respond_to do |format|
        format.js
      end

    end
  end

  def index
    authorize nil, :is_account?, policy_class: AccountPolicy

    @per_page = params[:per_page].present? ? params[:per_page] : 10

    begin
      @groups = Group.where(archived: false, account_id: $community_account.id).paginate(page: params[:page], per_page: @per_page)
    rescue
      @groups = Group.where(archived: false, account_id: current_account.id).paginate(page: params[:page], per_page: @per_page)
    end
  end

  def new
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @group = Group.new
    respond_to do |format|
      format.js
    end
  end

  def edit
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    respond_to do |format|
      format.js
    end
  end

  def create
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @group = Group.new(group_params)
    @group.account_id = $community_account.id
    @group.created_by_id = current_account.id

    respond_to do |format|
      if @group.save
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
        format.html {
          redirect_to all_group_surveys_path(@group)
          # , notice: 'Group was successfully created.'
        }
      else
        format.js { render :new }
      end
    end
  end

  def update
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy
    @per_page = params[:per_page].present? ? params[:per_page] : 10
    
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

    @group.update(group_params)

    begin
      @groups = Group.where(archived: false, account_id: $community_account.id).paginate(page: params[:page], per_page: @per_page)
    rescue
      @groups = Group.where(archived: false, account_id: current_account.id).paginate(page: params[:page], per_page: @per_page)
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    @group.update(archived: true)
    respond_to do |format|
      format.html {
        redirect_to groups_url
        # , notice: 'Group was successfully destroyed.'
      }
      format.json { head :no_content }
    end
  end

  private
  def set_group
    @group = Group.where(archived: false).find(params[:id])
  end

  def group_params
    params.require(:group).permit(:title, :account_id, :created_by_id)
  end

  def check_limitation
    if $community_account.survey_limit <= Survey.undeleted_survey.where(created_by_id: $community_account.id).to_a.size
      flash[:warning] = "You have reached your maximum survey amount of (#{$community_account.survey_limit})."
      respond_to do |format|
        format.html {redirect_to groups_path}
        format.js{

          render :js => "window.location.href = '#{groups_path}'" 
          return
        }
      end
    end
  end
end
