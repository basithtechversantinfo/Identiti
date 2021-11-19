class Admin::TemplateThemes::StepsController < AdminController
  layout 'survey_build'

  include Wicked::Wizard
  prepend_before_action :set_template_steps
  prepend_before_action :set_template_theme

  def show
    authorize nil, :is_admin?, policy_class: AdminPolicy


    render_wizard
  end

  def update
    authorize nil, :is_admin?, policy_class: AdminPolicy

    if params[:template_theme].present?
      @template.update(template_theme_params)
    end

    if params[:button] == "save-and-exit"
      redirect_to admin_template_themes_path
    else
      render_wizard @template
    end
  end

  def preview_survey
    respond_to do |format|
      format.html
    end
  end

  private

  def set_template_theme
    @template = TemplateTheme.find(params[:template_theme_id])

    if params[:id] == 'build'
      categories = if @template.industries.present?
                     if @template.industries.count == Industry.count
                       Category.all
                     else
                       Category.where(id: @template.industries.map{|c| c.category_ids}.flatten.uniq)
                     end
                   else
                     Category.all
                   end
      @categories = categories
      non_cloned_categories  = @template.categories.where.not(cloned: true)
      unless non_cloned_categories.blank?
        non_cloned_categories.each do |cat|
          find_block = CategoriesTemplateTheme.where(category_id: cat.id, template_theme_id: params[:template_theme_id] )

            if find_block.present?

              master_category = Category.find(cat.id)
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


        end   
      end
    end
  end

  def set_template_steps
    # self.steps = [:setup, :build, :respondents, :deliver]
    self.steps = [:setup, :build]
  end

  def template_theme_params
    params.require(:template_theme).permit(:title, :welcome_page, :thank_you_page, industry_ids: [])
  end

  def finish_wizard_path
    admin_template_themes_path
  end
end
