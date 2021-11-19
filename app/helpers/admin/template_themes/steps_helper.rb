module Admin::TemplateThemes::StepsHelper
  def set_theme_template_steps
    ['setup', 'build']
  end

  def active_or_done(template, step, current_step)
    if set_theme_template_steps.first == step
      if template.title.present? and current_step == step
        'wizard__item--done-v1'
        elsif template.title.present? and current_step != step
          'wizard__item--done'
      elsif !template.title.present? and current_step != step
        ''
      end
    elsif set_theme_template_steps.second == step
      if template.welcome_page.present? and current_step == step
        'wizard__item--done-v1'
      elsif template.welcome_page.present? and current_step != step
        'wizard__item--done'
      elsif !template.welcome_page.present? and current_step == step
        ''
      end
    end
  end

  def active_or_done_mobile(template, step, current_step)
    if set_theme_template_steps.first == step
      if template.title.present? and current_step == step
        'active yellow-btn'
        elsif template.title.present? and current_step != step
          'yellow-btn'
      elsif !template.title.present? and current_step == step
        'active'
      end
    elsif set_theme_template_steps.second == step
      if template.welcome_page.present? and current_step == step
        'active yellow-btn'
      elsif template.welcome_page.present? and current_step != step
        'yellow-btn'
      elsif !template.welcome_page.present? and current_step == step
        'active'
      end
    end
  end





end
