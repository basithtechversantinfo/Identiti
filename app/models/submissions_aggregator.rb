class SubmissionsAggregator
  include QuestionOptionsHelper

  attr_reader :submissions, :areas

  def initialize(submissions:, areas:)
    @submissions = submissions
    @areas = areas
    @score_map = Category.includes(:questions, questions: [:question_labels, :label_template]).find(areas).map {|c|
      [c.id.to_s, c.questions.map{|q|
        [q.id.to_s,

         if q.question_type == Question.question_types.key(8) || q.question_type == Question.question_types.key(6) || q.question_type == Question.question_types.key(5)

           [["data", ""]].to_h

         else
           if get_drop_down_question_options(q)[:options].present?
             unless q.question_type == Question.question_types.key(12)
              get_drop_down_question_options(q)[:options].map{|shape|
               (shape.is_a?(Array) ? [shape[0], shape[1]] : [shape, shape])}.to_h
             else
                {"1"=>"1", "2"=>"2", "3"=>"3", "4"=>"4", "5"=>"5"}
             end

           else
             [["data", ""]].to_h
           end

         end

        ]}.to_h
      ]}.to_h
  end

  def result
    map_hash_against_labels(@score_map)
  end

  private

  def map_hash_against_labels(score_map)
    response = Hash.new

    response["recipients"] = {}
    score_map.keys.each do |cat|
      response[cat] = {}
      response["recipients"][cat] = {}

      score_map[cat].keys.each do |ques|
        response[cat][ques] = {}
        response["recipients"][cat][ques] = {}

        score_map[cat][ques].keys.each do |ques_val|
          response[cat][ques][ques_val] = []
        end

        @submissions.each do |submission|
          response["recipients"][cat][ques][submission.id] = {}
          response["recipients"][cat][ques][submission.id][submission.recipient_id] = []
          # response["recipients"][cat][ques][submission.id][submission.recipient_id] << { other: []}

          begin
            if submission.data_json["data"][cat].present?

              if submission.data_json["data"][cat][ques].is_a?(Array)
                submission.data_json["data"][cat][ques].each do |sub_data_a|
                  if sub_data_a.include?("other")
                    response[cat][ques][score_map[cat][ques].key(sub_data_a)] << score_map[cat][ques].key(sub_data_a)
                    response["recipients"][cat][ques][submission.id][submission.recipient_id] << submission.data_json["other"][cat][ques]
                  else
                    response[cat][ques][score_map[cat][ques].key(sub_data_a)] << score_map[cat][ques].key(sub_data_a)
                    response["recipients"][cat][ques][submission.id][submission.recipient_id] << score_map[cat][ques].key(sub_data_a)
                  end
                end
              else
                if response[cat][ques].key?(score_map[cat][ques].key(submission.data_json["data"][cat][ques])).present?
                  if submission.data_json["data"][cat][ques].include?("other")
                    response["recipients"][cat][ques][submission.id][submission.recipient_id] << { other: []}
                    response[cat][ques][score_map[cat][ques].key(submission.data_json["data"][cat][ques])] << submission.data_json["data"][cat][ques]
                    response["recipients"][cat][ques][submission.id][submission.recipient_id] << submission.data_json["data"][cat][ques]
                    response["recipients"][cat][ques][submission.id][submission.recipient_id][0][:other] << submission.data_json["other"][cat][ques]
                  else
                    response[cat][ques][score_map[cat][ques].key(submission.data_json["data"][cat][ques])] << submission.data_json["data"][cat][ques]
                    response["recipients"][cat][ques][submission.id][submission.recipient_id] << submission.data_json["data"][cat][ques]
                  end
                else
                  response[cat][ques]["data"] << submission.data_json["data"][cat][ques]
                  response["recipients"][cat][ques][submission.id][submission.recipient_id] << submission.data_json["data"][cat][ques]
                end
              end

            end
          rescue
            # byebug
          end
        end

      end
    end

    return response
  end

  def count
    @_count ||= submissions.count
  end
end
