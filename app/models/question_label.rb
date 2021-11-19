class QuestionLabel < ApplicationRecord
  default_scope { order(position: :asc) }

  belongs_to :question, optional: true
  belongs_to :label_template, optional: true

  has_one_attached :image

  before_create :update_position

  attr_accessor :position_sorted, :branching

  def update_position
  	if self.new_record?
  	  unless self.position_sorted == '0'
        if self.question.present?
          p_question_labels = self.question.question_labels.select { |ql| !ql.new_record?  }
    	    self.position = p_question_labels.to_a.size + 1
        end
  	  end
  	end
  end
end
