class SubmissionAnswer < ApplicationRecord
  serialize :answer
  serialize :answer_other

  enum question_type: Question.question_types
  enum question_other_specify: Question.other_specifies
  ANSWER_DATA_TYPE_IDENTIFIERS =  {Question.question_types.key(0) => 'string',
                                   Question.question_types.key(4) => 'array',
                                   Question.question_types.key(1) => 'string',
                                   Question.question_types.key(2) => 'array',
                                   Question.question_types.key(3) => 'string',
                                   Question.question_types.key(5) => 'string',
                                   Question.question_types.key(6) => 'number',
                                   Question.question_types.key(12) => 'number',
                                   Question.question_types.key(7) => 'string',
                                   Question.question_types.key(77) => 'number',
                                   Question.question_types.key(8) => 'hash',
                                   Question.question_types.key(11) => 'date',
                                   Question.question_types.key(13) => 'string',
                                   Question.question_types.key(14) => 'string'
  }

  belongs_to :survey
  belongs_to :submission
  belongs_to :recipient
  belongs_to :category
  belongs_to :question
  belongs_to :recipient
end
