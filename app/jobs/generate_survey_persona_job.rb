class GenerateSurveyPersonaJob  < ApplicationJob
  queue_as :default
  include ApplicationHelper

  def perform(survey_id)
    @survey = Survey.find(survey_id)
    @recipients_results = @survey.submissions.present? ? @survey.aggregator_scoring.result.freeze : nil

    @survey.category_blocks.where(display_type: "profile").each do |cat|

      if @recipients_results.present? and @recipients_results[cat.id.to_s].present?

        cat.questions.each do |q|

          if @recipients_results[cat.id.to_s][q.id.to_s].present?

            if @recipients_results[cat.id.to_s][q.id.to_s].present?

              if !@recipients_results[cat.id.to_s][q.id.to_s].values.flatten.any? {|d| d.is_a?(Hash)}

                display_data = PersonaStatistics::Stats.new(@recipients_results[cat.id.to_s][q.id.to_s].values.flatten).mode_multi

                if display_data.include?("Male") || display_data.include?("Female") || display_data.include?("prefer not to anser") || display_data.include?("Prefer not to answer") || display_data.include?("prefer not to answer") || display_data.include?("Prefer not to answer ") || display_data.include?("prefer not to answer ")

                  hash = Hash[['Male', 'Female'].map {|x| [x, 0]}]

                  filtered_display_data = display_data.select {|r| r == "Male" || r == "Female" }
                  labels_with_count = filtered_display_data.inject(hash) {|h,i| h[i] += 1; h }


                  get_gender = if labels_with_count["Male"] == labels_with_count["Female"]
                                 'Neutral'
                               elsif labels_with_count["Male"] > labels_with_count["Female"]
                                 'Male'
                               elsif labels_with_count["Female"] > labels_with_count["Male"]
                                 'Female'
                               else
                                 'No Answer'
                               end

                  persona = PersonaIdentifier.new(get_gender)

                  @survey.update(gender: persona.gender, gender_image_slug: persona.gender_image_slug, gender_full_name: persona.gender_name)

                end

              end

            end
          end
        end

      end
    end

  end
end