module ResultsHelper

  def question_answers(results, category, question)
    begin
      if results[category.id.to_s].present?
        begin
          if Question.question_types.key(4) == question.question_type || Question.question_types.key(2) == question.question_type || Question.question_types.key(13) == question.question_type || Question.question_types.key(14) == question.question_type
            if Question.question_types.key(13) == question.question_type
              if question.label_template.slug_id == 'system-custom4'

                results["recipients"][category.id.to_s][question.id.to_s].map{|a| a[1].values.flatten.blank?}.count(false)

              else
                results[category.id.to_s][question.id.to_s].values.flatten.reject(&:blank?).count
              end

            elsif Question.question_types.key(4) == question.question_type
              results["recipients"][category.id.to_s][question.id.to_s].map{|a| a[1].values.flatten.blank?}.count(false)
            else
              if Question.question_types.key(14) == question.question_type
                i=0
                results["recipients"][category.id.to_s][question.id.to_s].values.map{|a| a.values}.flatten.each do |ans|
                  if question.question_labels.select{|a| a.correct_answer == true}.pluck(:label).include?(ans)
                    i = i + 1
                  end
                end
                i
              else
                results["recipients"][category.id.to_s][question.id.to_s].count
              end
            end
          else
            results[category.id.to_s][question.id.to_s].values.flatten.reject(&:blank?).count
          end
        rescue
          0
        end
      else
        0
      end
    rescue
      0
    end
  end


  def nps_calculator(data_array)
    data_array.map! {|v| v.to_i}

    count = data_array.each_with_object(Hash.new(0)) do |e, memo|
      case e
      when 0..6 then memo[:detractors] += 1
      when 7..8 then memo[:passives] += 1
      when 9..10 then memo[:promoters] += 1
      end
    end

    score = (count[:promoters] - count[:detractors]).to_f / data_array.size * 100

    return {total_score: score.round(2), promoters: count[:promoters], passives: count[:passives], detractors: count[:detractors]}
  end

  def wordcloud_results(text_array)
    begin
      text = text_array.to_sentence
      rake = RakeText.new
      rake.analyse text, RakeText.SMART, true
    rescue
      {"No Results"=>1}
    end
  end
end
