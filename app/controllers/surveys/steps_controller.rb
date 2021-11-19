class Surveys::StepsController < ApplicationController
  layout 'survey_build'

  include Wicked::Wizard
  include SurveysHelper
  prepend_before_action :set_survey_steps
  prepend_before_action :set_survey
  after_action :make_survey_draft_state, only: [:update]
  # prepend_before_action :set_group
  
  def make_survey_draft_state
    if params[:button] == "Activate"
     if @survey.survey_state == "Draft"
       value1 = @survey.update_attribute(:survey_state,"Active") 
     end
    elsif params[:button] == "save-and-exit"
      value2 = @survey.update_attribute(:survey_state,"Draft")
    end
  end

  def show
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy
    authorize @survey.group.account, :can_view?, policy_class: AccountPolicy

    @q_count = @survey.categories_surveys.map{|c| c.category.questions.to_a.count }.sum
    render_wizard
  end

  def update
    authorize nil, :is_account?, policy_class: AccountPolicy
    authorize $community_account, :can_add_edit_delete_global?, policy_class: AccountPolicy

    if params[:survey].present?
      survey_params_decider = @locked ? survey_locked_params : survey_params

      if params[:survey][:delivery_start_at].present?
        @survey.update(survey_params_decider.merge(
            delivery_start_at: Time.at(params[:survey][:delivery_start_at].to_i).to_s,
            delivery_end_at: Time.at(params[:survey][:delivery_end_at].to_i).to_s
        ))
      else
        @survey.update(survey_params_decider)
      end

      


      if params.key?("get_sharable_link") && params.key?("recipients_list") && all_step_valid_survey(@survey)
          @survey.update(survey_state: 1)
        #return redirect_to results_group_survey_path(@survey.group_id, @survey)
         
         return redirect_to all_group_surveys_url(@survey.group_id)  
      end

      if params[:survey][:group_id].present?
        @survey.custom_personas.update_all(group_id: params[:survey][:group_id])
      end
      unless params[:survey][:list_ids].present?
        if params[:id] == "respondents"
          @survey.get_sharable_link = params[:survey][:get_sharable_link]
          @survey.non_email_link = params[:select_respondents] == "noemail" ? true : false
          @survey.list_ids =[]
          @survey.save
        end
      end
      
    end
    
   

    if params[:button] == "save-and-exit"

      if @locked
        redirect_to results_group_survey_path(@survey.group_id, @survey)
      else
        redirect_to all_group_surveys_url(@survey.group_id)
      end

    else
      
      if params[:show_description_field].present?
        redirect_to survey_step_path(@survey, "build")
      elsif params[:show_block_name_field].present?
        redirect_to survey_step_path(@survey, "build")
      else
        render_wizard @survey
      end
    end
  end

  private

  def set_survey
    @survey = Survey.includes(:recipients_surveys, :categories_surveys, categories_surveys: [category: [:questions]], lists: [:recipients, :lists_recipients]).find(params[:survey_id]) rescue nil

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

    # if params[:id] == 'build'
    #   categories = if @template.industries.present?
    #                  if @template.industries.count == Industry.count
    #                    Category.all
    #                  else
    #                    Category.find(@template.industries.map{|c| c.category_ids}.flatten.uniq)
    #                  end
    #                else
    #                  Category.all
    #                end
    #   @categories = categories
    # end
  end

  def set_survey_steps
    if @locked
      self.steps = [:setup, :build, :respondents, :display_type, :deliver]
    else
      self.steps = [:setup, :build, :respondents, :display_type, :deliver, :send_survey]
    end
  end

  def survey_params
    params.require(:survey).permit(:title, :email_from, :email_sender, :email_subject, :delivery_end_at,
                                   :delivery_start_at, :delivery_time, :group_id, :persona_summary_display_type,
                                   :thank_you_page, :welcome_page, :show_descriptions, :show_block_name, :get_sharable_link,
                                   recipients_surveys_attributes: [:id, :survey_id, :allow_survey, :recipient_id, :list_id, :_destroy],
                                   industry_ids: [], list_ids: [])
  end

  def survey_locked_params
    params.require(:survey).permit(:delivery_start_at, :delivery_end_at, :delivery_time, :group_id, :show_descriptions, :show_block_name, :persona_summary_display_type,
                                   :thank_you_page, :welcome_page,
                                   recipients_surveys_attributes: [:id, :survey_id, :allow_survey, :recipient_id, :list_id, :_destroy], industry_ids: [])
  end

  def finish_wizard_path

    if @locked

      results_group_survey_path(@survey.group_id, @survey)

    else
     
      if all_step_valid_survey(@survey)

         Recipient.find(@survey.recipients_surveys.where(allow_survey: "true").pluck(:recipient_id).uniq).each do |recipient|
           puts"======#{params[:locale]}====#{recipient.inspect}====#{@survey.inspect}====="
           AccountMailer.send_submission_links(params[:locale], recipient, @survey).deliver_later
         end

        @survey.update(survey_state: 1)
        success_survey_path(@survey)

      else

        survey_step_path(@survey, first_invalid_step_survey(@survey))

      end

    end

  end
end
