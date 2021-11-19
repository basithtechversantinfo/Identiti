class AddAdditionalColumnsToSubmissionAnswers < ActiveRecord::Migration[5.2]
  def change
    add_column :submission_answers, :answers_target, :jsonb
    add_index :submission_answers, :answers_target, using: :gin

    add_column :submission_answers, :score, :jsonb
    add_index :submission_answers, :score, using: :gin

    add_column :submission_answers, :score_target, :jsonb
    add_index :submission_answers, :score_target, using: :gin

    add_column :submission_answers, :answers_target_additional, :jsonb, default: nil
    add_index :submission_answers, :answers_target_additional, using: :gin
  end
end
