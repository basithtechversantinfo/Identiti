module SurveysHelper

  def set_survey_steps
      ['setup', 'build', 'respondents', 'display_type', 'deliver']
  end

  def all_step_valid_survey(survey)
    if !survey.title.present?
      false
    elsif !survey.welcome_page.present?
      false
    elsif (!survey.lists.present? || !survey.recipients_surveys.where(allow_survey: "true").present?) && (!survey.get_sharable_link)
      false
    elsif !survey.delivery_time.present?
      false
    elsif !survey.persona_summary_display_type.present?
      false
    else
      true
    end
  end

  def first_invalid_step_survey(survey)
    if !survey.title.present?
      'setup'
    elsif !survey.welcome_page.present?
      'build'
    elsif !survey.lists.present? || !survey.recipients_surveys.where(allow_survey: "true").present?
      'respondents'
    elsif !survey.persona_summary_display_type.present?
      'display_type'
    elsif !survey.delivery_time.present?
      'deliver'
    else
      ''
    end
  end

  def active_or_done_survey(template, step, current_step)
    if set_survey_steps.first == step
      if template.title.present? and current_step == step
        'wizard__item--done-v1'
      elsif template.title.present? and current_step != step
        'wizard__item--done'
      elsif !template.title.present? and current_step != step
        ''
      end

    elsif set_survey_steps.second == step
      if template.welcome_page.present? and current_step == step
        'wizard__item--done-v1'
      elsif template.welcome_page.present? and current_step != step
        'wizard__item--done'
      elsif !template.welcome_page.present? and current_step == step
        ''
      end

    elsif set_survey_steps.third == step
      if template.lists.present? and template.recipients_surveys.where(allow_survey: "true").present? and current_step == step
        'wizard__item--done-v1'
      elsif template.lists.present? and template.recipients_surveys.where(allow_survey: "true").present? and current_step != step
        'wizard__item--done'
      elsif template.get_sharable_link == true && current_step != step
        'wizard__item--done'
      elsif template.get_sharable_link == true && current_step == step
        'wizard__item--done-v1'
      elsif !template.lists.present? and current_step == step
        ''
      end

    elsif set_survey_steps.fourth == step
      if template.persona_summary_display_type.present? and current_step == step
        'wizard__item--done-v1'
      elsif template.persona_summary_display_type.present? and current_step != step
        'wizard__item--done'
      elsif !template.persona_summary_display_type.present? and current_step == step
        ''
      end

    elsif set_survey_steps.fifth == step
      if template.delivery_time.present? and current_step == step
        'wizard__item--done-v1'
      elsif template.delivery_time.present? and current_step != step
        'wizard__item--done'
      elsif !template.delivery_time.present? and current_step == step
        ''
      end
    end
  end

  def active_or_done_mobile_survey(template, step, current_step)
    if set_survey_steps.first == step
      if template.title.present? and current_step == step
        'active yellow-btn'
      elsif template.title.present? and current_step != step
        'yellow-btn'
      elsif !template.title.present? and current_step == step
        'active'
      end

    elsif set_survey_steps.second == step
      if template.welcome_page.present? and current_step == step
        'active yellow-btn'
      elsif template.welcome_page.present? and current_step != step
        'yellow-btn'
      elsif !template.welcome_page.present? and current_step == step
        'active'
      end

    elsif set_survey_steps.third == step
      if template.lists.present? and template.recipients_surveys.where(allow_survey: "true").present? and current_step == step
        'active yellow-btn'
      elsif template.lists.present? and template.recipients_surveys.where(allow_survey: "true").present? and current_step != step
        'yellow-btn'
      elsif !template.lists.present? and current_step == step
        'active'
      end

    elsif set_survey_steps.fourth == step
      if template.persona_summary_display_type.present? and current_step == step
        'active yellow-btn'
      elsif template.persona_summary_display_type.present? and current_step != step
        'yellow-btn'
      elsif !template.persona_summary_display_type.present? and current_step == step
        'active'
      end

    elsif set_survey_steps.fifth == step
      if template.delivery_time.present? and current_step == step
        'active yellow-btn'
      elsif template.delivery_time.present? and current_step != step
        'yellow-btn'
      elsif !template.delivery_time.present? and current_step == step
        'active'
      end
    end
  end

  def sender_from_title
    if $community_account.company_name.present?
      $community_account.company_name
    else
      $community_account.your_name
    end
  end

  def sender_emails
    if $community_account.company_name.present?
      [$community_account.company_email]
    else
      [$community_account.sender_email]
    end
  end

end
