class SurveySubmissionsController < ApplicationController
  layout "survey_build"

  skip_before_action :authenticate_account!
  before_action :set_survey
  before_action :set_decrypted_mail, :check_survey, :screen, only: [:start]
  before_action :email_check_for_survey_submission, only: [:continue]
  before_action :check_delivery_end, only: [:start]

  def start
    if params['survey_token'].present? and params['encr_mail_id'].present?
      if @survey.delivery_end_at.utc < Time.now.utc || !@survey.enable_share? || @survey.deleted_at != nil
        redirect_to not_found_path(error_message: "survey_not_exists") 
        return
      end
      if set_recipient_by_decrpted_email
        if @survey.submissions.present? and @survey.submissions.pluck(:recipient_id).include?(set_recipient_by_decrpted_email.id)
          render template: 'survey_submissions/start', locals: { error: 'Sorry you have already submitted this survey', email: @decrypted_mail}
        else

          # unless @survey.categories.select{|c| c.questions.pluck(:question_type).include?("Screener")}.blank?
          #  render template: 'survey_submissions/screen',
          #  locals: {
          #      submission: Submission.new(
          #          recipient_id: set_recipient_by_decrpted_email.id,
          #          survey_id: @survey.id,
          #          decrypted_mail: @decrypted_mail
          #      ),
          #      s_t: "true"
          #  }
          #  return
          # else 
          #   render template: 'survey_submissions/new',
          #      locals: {
          #          submission: Submission.new(
          #              recipient_id: set_recipient_by_decrpted_email.id,
          #              survey_id: @survey.id,
          #              decrypted_mail: @decrypted_mail
          #          )
          #      }
          # end
          render template: 'survey_submissions/start', locals: { 
                   submission: Submission.new(
                       recipient_id: set_recipient_by_decrpted_email.id,
                       survey_id: @survey.id,
                       decrypted_mail: @decrypted_mail
                   ),     error: nil }
        end
      else
        @survey = nil
        render template: 'survey_submissions/start', locals: { error: nil, email: nil }
      end

    elsif params['survey_token'].present? && (@survey.non_email_link==true && @survey.get_sharable_link==true)

      if @survey.delivery_end_at.utc < Time.now.utc || !@survey.enable_share? || @survey.deleted_at != nil
        redirect_to not_found_path(error_message: "survey_not_exists") 
        return
      end
      # recipient = Recipient.find_or_create_by(account_id: @survey.group.account_id, email: Faker::Internet.email, created_by_id: @survey.group.account_id)
      # recipient.save
      # unless @survey.categories.select{|c| c.questions.pluck(:question_type).include?("Screener")}.blank?
      #      render template: 'survey_submissions/screen',
      #      locals: {
      #          submission: Submission.new(
      #              recipient_id: recipient.id,
      #              survey_id: @survey.id,
      #              decrypted_mail: recipient.email
      #          ),
      #          s_t: "true"
      #      }
      #      return
      # else 


      # render template: 'survey_submissions/new',
      #      locals: {
      #          submission: Submission.new(
      #              recipient_id: recipient.id,
      #              survey_id: @survey.id,
      #              decrypted_mail: recipient.email
      #          )
      #      }
      # end
      render template: 'survey_submissions/start', locals: { error: nil, email: nil }
    else
      if @survey.delivery_end_at.utc < Time.now.utc || !@survey.enable_share?
        redirect_to not_found_path(error_message: "survey_not_exists") || @survey.deleted_at != nil
        return
      end
      @survey = nil if not @survey.get_sharable_link
      render template: 'survey_submissions/start', locals: { error: nil, email: nil }
    end
  end

  def continue
    unless (@survey.non_email_link==true && @survey.get_sharable_link==true)
      if @survey.lists.present? && @survey.recipients_surveys.where(allow_survey: "true").present?
         @decrypted_mail = params[:d_email]
         unless @survey.categories.select{|c| c.questions.pluck(:question_type).include?("Screener")}.blank?
           render template: 'survey_submissions/screen',
           locals: {
               submission: Submission.new(
                   recipient_id: set_recipient_by_decrpted_email.id,
                   survey_id: @survey.id,
                   decrypted_mail: @decrypted_mail
               ),
               s_t: "true"
           }
           return
          else 
            render template: 'survey_submissions/new',
               locals: {
                   submission: Submission.new(
                       recipient_id: set_recipient_by_decrpted_email.id,
                       survey_id: @survey.id,
                       decrypted_mail: @decrypted_mail
                   )
               }
          end
      else

        begin
          custom_configuration = Truemail::Configuration.new do |config|
            config.verifier_email = params[:survey_continue][:email]
          end
        rescue
          return render template: 'survey_submissions/start', locals: { error: 'Please enter Valid Email address to continue..', email: params[:survey_continue][:email]}
        end

        validate = Truemail.validate(params[:survey_continue][:email], custom_configuration: custom_configuration)
        valid = Truemail.valid?(params[:survey_continue][:email], custom_configuration: custom_configuration)

        if validate.result.success && valid
          recipient = Recipient.find_or_create_by(account_id: @survey.group.account_id, email: params[:survey_continue][:email], created_by_id: @survey.group.account_id)
          recipient.save
          if @survey.list_ids.present?
            ListsRecipient.find_or_create_by(recipient_id: recipient.id, list_id: @survey.list_ids[0])
            @survey.recipients_surveys.find_or_create_by(recipient_id: recipient.id, allow_survey: "true", list_id: @survey.list_ids[0])
          else
            list_id = List.find_or_create_by(title: @survey.title.to_str[0, 10]+"-From Sharable link", account_id: @survey.group.account_id)
            ListsRecipient.find_or_create_by(recipient_id: recipient.id, list_id: list_id.id)
            @survey.recipients_surveys.find_or_create_by(recipient_id: recipient.id, allow_survey: "true", list_id: list_id.id)
          end
        else
          return render template: 'survey_submissions/start', locals: { error: 'Please enter Valid Email address to continue..', email: params[:survey_continue][:email]}
        end

        recipients =
            begin
              @survey.recipients_surveys.where(allow_survey: "true").pluck(:recipient_id)
            rescue
              []
            end

        if recipients.present? and set_recipient_by_email.present? and recipients.include?(set_recipient_by_email.id)
          if @survey.submissions.present? and @survey.submissions.pluck(:recipient_id).include?(set_recipient_by_email.id)
            render template: 'survey_submissions/start', locals: { error: 'Sorry you have already submitted this survey', email: params[:survey_continue][:email]}
          else
            unless @survey.categories.select{|c| c.questions.pluck(:question_type).include?("Screener")}.blank?
               render template: 'survey_submissions/screen',
               locals: {
                   submission: Submission.new(
                       recipient_id: recipient.id,
                       survey_id: @survey.id,
                       decrypted_mail: recipient.email
                   ),
                   s_t: "true"
               }
               return
          else 


            render template: 'survey_submissions/new',
                     locals: {
                         submission: Submission.new(
                             survey_id: @survey.id,
                             recipient_id: set_recipient_by_email.id,
                             decrypted_mail: @decrypted_mail
                         )
                     }
          end
            
          end
        else
          render template: 'survey_submissions/start', locals: { error: 'Please enter Valid Email address to continue', email: params[:survey_continue][:email]}
        end
      end
    else
      recipient = Recipient.find_or_create_by(account_id: @survey.group.account_id, email: Faker::Internet.email, created_by_id: @survey.group.account_id)
      recipient.save
      unless @survey.categories.select{|c| c.questions.pluck(:question_type).include?("Screener")}.blank?
           render template: 'survey_submissions/screen',
           locals: {
               submission: Submission.new(
                   recipient_id: recipient.id,
                   survey_id: @survey.id,
                   decrypted_mail: recipient.email
               ),
               s_t: "true"
           }
           return
      else 


      render template: 'survey_submissions/new',
           locals: {
               submission: Submission.new(
                   recipient_id: recipient.id,
                   survey_id: @survey.id,
                   decrypted_mail: recipient.email
               )
           }
      end
    end
  end

  def new; end
  def show; end

  def screen
    
  end

  def screen_submit
    screening_blocks = @survey.categories.select{|c| c.questions.pluck(:question_type).include?("Screener")}
    if screening_blocks.present?
      correct_ans = []
      screening_blocks.each do |s_id|
        submission_params["data_json"]["data"][s_id["id"].to_s].to_h.each do |a, b|
           correct_ans << Question.find(a.to_i).question_labels.find_by(label: b).correct_answer.to_s
        end
      end
        # binding.pry
      if correct_ans.any?{|a| a=="false"}
        set_decrypted_mail if params['encr_mail_id'].present?
        @survey.recipients_surveys.find_or_create_by!(recipient_id: params[:submission][:recipient_id], allow_survey: "true") if (@survey.get_sharable_link ==true && @survey.non_email_link == true)
        recipients =
            begin
              @survey.recipients_surveys.where(allow_survey: "true").pluck(:recipient_id)
            rescue
              []
            end
        if recipients.present? and set_recipient_by_id.present? and recipients.include?(set_recipient_by_id.id)

          if @survey.submissions.present? and @survey.submissions.pluck(:recipient_id).include?(set_recipient_by_id.id)
            render template: 'survey_submissions/start', locals: { error: 'Sorry you have already submitted this survey', email: set_recipient_by_id.id}
          else

            new_submission = Submission.new(submission_params)

            # Generate persona
            persona = PersonaIdentifier.new(new_submission.data_json)
            new_submission.gender = persona.gender
            new_submission.gender_image_slug = persona.gender_image_slug
            new_submission.full_name = persona.gender_name


            new_submission.survey_eligibility = 1

            if new_submission.save
              render :screen_exit,
                     locals: {
                         submission: Submission.new(submission_params),
                         survey_token: params[:survey_token],
                         locale: params[:locale],
                         decrypted_mail: @decrypted_mail
                     }
            else
              render :new,
                     locals: {
                         submission: Submission.new(submission_params)
                     }

            end
          end

        else
          render template: 'survey_submissions/start', locals: { error: 'Please enter Valid Email address to continue', email: set_recipient_by_id.email}
        end
      else
        # recipient = @survey.recipients_surveys.find_or_create_by!(recipient_id: params[:submission][:recipient_id], allow_survey: "true").recipient
        recipient = Recipient.find(params[:submission][:recipient_id])
        render template: 'survey_submissions/new',
               locals: {
                   submission: Submission.new(submission_params),
                       recipient_id: recipient.id,
                       survey_id: @survey.id,
                       decrypted_mail: recipient.email
                   
               }
      end
    end
    

    
  end

  def create
    set_decrypted_mail if params['encr_mail_id'].present?
    @survey.recipients_surveys.find_or_create_by!(recipient_id: params[:submission][:recipient_id], allow_survey: "true") if (@survey.get_sharable_link ==true && @survey.non_email_link == true)
    recipients =
        begin
          @survey.recipients_surveys.where(allow_survey: "true").pluck(:recipient_id)
        rescue
          []
        end
    if recipients.present? and set_recipient_by_id.present? and recipients.include?(set_recipient_by_id.id)

      if @survey.submissions.present? and @survey.submissions.pluck(:recipient_id).include?(set_recipient_by_id.id)
        render template: 'survey_submissions/start', locals: { error: 'Sorry you have already submitted this survey', email: set_recipient_by_id.id}
      else

        new_submission = Submission.new(submission_params)

        # Generate persona
        persona = PersonaIdentifier.new(new_submission.data_json)
        new_submission.gender = persona.gender
        new_submission.gender_image_slug = persona.gender_image_slug
        new_submission.full_name = persona.gender_name

        if new_submission.save
          render :show,
                 locals: {
                     submission: Submission.new(submission_params),
                     survey_token: params[:survey_token],
                     locale: params[:locale],
                     decrypted_mail: @decrypted_mail
                 }
        else
          render :new,
                 locals: {
                     submission: Submission.new(submission_params)
                 }

        end
      end

    else
      render template: 'survey_submissions/start', locals: { error: 'Please enter Valid Email address to continue', email: set_recipient_by_id.email}
    end
  end

  private
  def set_survey
    @survey = Survey.find_by_survey_token(params[:survey_token])
  end

  def check_survey
    @survey = Survey.find_by_survey_token(params[:survey_token])
    if @survey.nil?
      return redirect_to not_found_path(error_message: "survey_not_exists")
    end
  end

  def set_decrypted_mail
    if params['survey_token'].present? && params['encr_mail_id'].present?
      begin
        key = ENV['ENCRYPT_KEY'].bytes[0..31].pack( "c" * 32 )
        crypt = ActiveSupport::MessageEncryptor.new(key)
        @decrypted_mail = crypt.decrypt_and_verify(params['encr_mail_id'])
      rescue
        @decrypted_mail = "error"
      end
    else
      @decrypted_mail = nil
    end
  end

  def set_recipient_by_email
    begin
      Recipient.where(email: params[:survey_continue][:email], account_id: @survey.group.account_id).first
    rescue
      nil
    end
  end

  def set_recipient_by_decrpted_email
    begin
      Recipient.where(email: @decrypted_mail, account_id: @survey.group.account_id).first
    rescue
      nil
    end
  end


  def set_recipient_by_id
    begin
      Recipient.where(id: params[:recipient_id], account_id: @survey.group.account_id).first
    rescue
      nil
    end
  end


  def submission_params
    params.require(:submission).permit(
        :recipient_id,
        :survey_id,
        :status,
        :gender,
        :full_name,
        :gender_image_slug,
        :total_time,
        :decrypted_mail,
        submission_category_time_spent: {},
        submission_question_time_spent: {},
        data_json: {}
    )
  end

  def email_check_for_survey_submission
    
    unless (@survey.non_email_link==true && @survey.get_sharable_link==true || params[:d_email].present?)
      unless params[:survey_continue][:email].present?
        return render template: 'survey_submissions/start', locals: { error: "Email address can't be blank.", email: params[:survey_continue][:email]}
      end
      
    end
  end

  def check_delivery_end
    if @survey.delivery_end_at.nil?
      redirect_to not_found_path(error_message: "survey_not_exists") 
      return 
    end
  end
end
