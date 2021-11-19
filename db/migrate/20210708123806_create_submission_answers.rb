class CreateSubmissionAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :submission_answers do |t|
      t.text :answer
      t.text :label
      t.text :answer_other
      t.text :answer_data_type
      t.text :time_spent
      t.text :block_type

      t.text :question_title
      t.text :question_description
      t.integer :question_type
      t.integer :question_other_specify

      t.text :category_title
      t.text :category_description
      t.text :category_display_type

      t.references :survey, foreign_key: true
      t.references :submission, foreign_key: true
      t.references :recipient, foreign_key: true
      t.references :question, foreign_key: true
      t.references :category, foreign_key: true

      t.timestamps
    end
  end
end