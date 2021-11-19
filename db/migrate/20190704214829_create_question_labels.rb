class CreateQuestionLabels < ActiveRecord::Migration[5.2]
  def change
    create_table :question_labels do |t|
      t.string :label
      t.references :question, foreign_key: true

      t.timestamps
    end
  end
end
