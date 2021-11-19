module QuestionOptionsHelper

  def get_drop_down_question_options_with_scored(question)
    if (question.present? and question.label_template_id != 0 and question.label_template.present? and question.label_template.slug_id != 'system-custom1' and question.label_template.slug_id != 'system-custom2' and question.label_template.slug_id != 'system-custom3' and question.label_template.slug_id != 'system-custom4')
      get_label_or_label_with_score(question, question.label_template.question_labels)
    elsif question.present? and question.label_template_id == 0
      get_label_or_label_with_score(question, question.question_labels)
    elsif (question.present? and question.label_template_id != 0 and question.label_template.present? and question.label_template.slug_id == 'system-custom1')
      get_label_or_label_with_score(question, question.question_labels)
    elsif (question.present? and question.label_template_id != 0 and question.label_template.present? and question.label_template.slug_id == 'system-custom2')
      get_label_or_label_with_score(question, question.question_labels)
    else
      get_label_or_label_with_score(question, question.question_labels)
    end
  end

  def get_label_or_label_with_score(question, question_labels)
    if question_labels.present?
      only_labels = question_labels.pluck(:id, :label).map { |id, label| {id: id, label: label}}
      labels_with_scores = question_labels.pluck(:id, :label, :score).map { |id, label, score| {id: id, label: label, score: score}}
      show_labels = question_labels.pluck(:show_label, :label)
      show_tags = question_labels.pluck(:show_tag, :tag)

      if get_selected_template(question) != I18n.t('surveys.custom') and get_selected_template(question) != I18n.t('surveys.custom_with_scores') and get_selected_template(question) != 'Single Select' and get_selected_template(question) != 'Multiple Select' 
        if question_labels.pluck(:score).any? {|x| x.present?}
          {data: labels_with_scores, options: labels_with_scores.pluck(:label, :score), show_labels: show_labels, show_tags: show_tags, question_type: question.question_type, question_required: question.required, question_title: question.title, question_description: question.description, question_id: question.id, category_id: question.category_id}
        else
          {data: only_labels, options: only_labels.pluck(:label), show_labels: show_labels, show_tags: show_tags, question_type: question.question_type, question_required: question.required, question_title: question.title, question_description: question.description, question_id: question.id, category_id: question.category_id}
        end
      elsif get_selected_template(question) == I18n.t('surveys.custom')
        {data: only_labels, options: only_labels.pluck(:label), show_labels: show_labels, show_tags: show_tags, question_type: question.question_type, question_required: question.required, question_title: question.title, question_description: question.description, other_specify: Question.other_specifies.key(0) == question.other_specify ? true : false, question_id: question.id, category_id: question.category_id }
      elsif get_selected_template(question) == 'Single Select' || get_selected_template(question) == 'Multiple Select'
        {data: only_labels, options: only_labels.pluck(:label), show_labels: show_labels, show_tags: show_tags, question_type: question.question_type, question_required: question.required, question_title: question.title, question_description: question.description, other_specify: Question.other_specifies.key(0) == question.other_specify ? true : false, question_id: question.id, category_id: question.category_id }
      else
        {data: labels_with_scores, options: labels_with_scores.pluck(:label, :score), show_labels: show_labels, show_tags: show_tags, question_type: question.question_type, question_required: question.required, question_title: question.title, question_description: question.description, other_specify: Question.other_specifies.key(0) == question.other_specify ? true : false, question_id: question.id, category_id: question.category_id }
      end

    else
      {data: {}, options: [], show_labels: [], show_tags: [], question_type: question.question_type, question_required: question.required, question_title: question.title, question_description: question.description, other_specify: Question.other_specifies.key(0) == question.other_specify ? true : false, question_id: question.id, category_id: question.category_id }
    end
  end

  def get_drop_down_question_options(question)
    if (question.present? and question.label_template_id != 0 and question.label_template.present? and question.label_template.slug_id != 'system-custom1' and question.label_template.slug_id != 'system-custom2' and question.label_template.slug_id != 'system-custom3' and question.label_template.slug_id != 'system-custom4')
      get_labels(question, question.label_template.question_labels)
    elsif question.present? and question.label_template_id == 0
      get_labels(question, question.question_labels)
    elsif (question.present? and question.label_template_id != 0 and question.label_template.present? and question.label_template.slug_id == 'system-custom1' )
      get_labels(question, question.question_labels)
    elsif (question.present? and question.label_template_id != 0 and question.label_template.present? and question.label_template.slug_id == 'system-custom2')
      get_labels(question, question.question_labels)
    elsif (question.present? and question.label_template_id != 0 and question.label_template.present? and question.label_template.slug_id == 'system-custom3')
      get_labels(question, question.question_labels)
    elsif (question.present? and question.label_template_id != 0 and question.label_template.present? and question.label_template.slug_id == 'system-custom4')
      get_labels(question, question.question_labels)
    else
      get_labels(question, question.question_labels)
    end
  end

  def get_labels(question, question_labels)
    if question_labels.present?
      only_labels = question_labels.pluck(:id, :label).map { |id, label| {id: id, label: label}}
      show_labels = question_labels.pluck(:show_label, :label)
      show_tags = question_labels.pluck(:show_tag, :tag)

      if get_selected_template(question) != I18n.t('surveys.custom') and get_selected_template(question) != I18n.t('surveys.custom_with_scores') and get_selected_template(question) != 'Single Select' and get_selected_template(question) != 'Multiple Select' 
          {data: only_labels, options: Question.other_specifies.key(0) == question.other_specify ? only_labels.pluck(:label) << "other" : only_labels.pluck(:label), show_labels: show_labels, show_tags: show_tags, question_type: question.question_type, question_required: question.required, question_title: question.title, question_description: question.description, question_id: question.id, category_id: question.category_id}
      elsif get_selected_template(question) == I18n.t('surveys.custom')
        {data: only_labels, options: Question.other_specifies.key(0) == question.other_specify ? only_labels.pluck(:label) << "other" : only_labels.pluck(:label), show_labels: show_labels, show_tags: show_tags, question_type: question.question_type, question_required: question.required, question_title: question.title, question_description: question.description, other_specify: Question.other_specifies.key(0) == question.other_specify ? true : false, question_id: question.id, category_id: question.category_id }
      else
        {data: only_labels, options: Question.other_specifies.key(0) == question.other_specify ? only_labels.pluck(:label) << "other" : only_labels.pluck(:label), show_labels: show_labels, show_tags: show_tags, question_type: question.question_type, question_required: question.required, question_title: question.title, question_description: question.description, other_specify: Question.other_specifies.key(0) == question.other_specify ? true : false, question_id: question.id, category_id: question.category_id }
      end

    else
      {data: {}, options: [], show_labels: [], show_tags: [], question_type: question.question_type, question_required: question.required, question_title: question.title, question_description: question.description, other_specify: Question.other_specifies.key(0) == question.other_specify ? true : false, question_id: question.id, category_id: question.category_id }
    end
  end

  def get_selected_template(question)
    if (question.present? and question.label_template_id != 0 and question.label_template.present? and question.label_template.slug_id != 'system-custom1' and question.label_template.slug_id != 'system-custom2' and question.label_template.slug_id != 'system-custom3' and question.label_template.slug_id != 'system-custom4')
      question.label_template_id
    elsif question.present? and question.label_template_id == 0
      I18n.t('surveys.custom')
    elsif (question.present? and question.label_template_id != 0 and question.label_template.present? and question.label_template.slug_id == 'system-custom1')
      I18n.t('surveys.custom')
    elsif (question.present? and question.label_template_id != 0 and question.label_template.present? and question.label_template.slug_id == 'system-custom2')
      I18n.t('surveys.custom_with_scores')
    elsif (question.present? and question.label_template_id != 0 and question.label_template.present? and question.label_template.slug_id == 'system-custom3')
      'Single Select'
    elsif (question.present? and question.label_template_id != 0 and question.label_template.present? and question.label_template.slug_id == 'system-custom4')
      'Multiple Select'
    else
      ''
    end
  end

  def get_custom_options(question)
    custom = ["#{t 'surveys.custom'}"]
    custom_with_scores = ["#{t 'surveys.custom'}", "#{t 'surveys.custom_with_scores'}"]
    visual_choices = ["Single Select", "Multiple Select"]
    branching = ["#{t 'surveys.branch'}"]

    if params[:question_type] == Question.question_types.key(0)
      if !question.nil? && question.is_branching? 
        branching
      else
        custom_with_scores
      end
    elsif params[:question_type] == Question.question_types.key(4)
      custom_with_scores
    elsif params[:question_type] == Question.question_types.key(1)
      custom_with_scores
    elsif params[:question_type] == Question.question_types.key(2)
      custom_with_scores
    elsif params[:question_type] == Question.question_types.key(3)
      custom_with_scores
    elsif params[:question_type] == Question.question_types.key(7)
      custom_with_scores
    elsif params[:question_type] == Question.question_types.key(13)
        visual_choices
    else
      custom
    end
  end
end
