class CreateQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :questions do |t|
      t.string :title
      t.text :description
      t.string :question_type
      t.boolean :required, default: true
      t.string :chart_type
      t.references :category, foreign_key: true

      t.timestamps
    end
  end
end
