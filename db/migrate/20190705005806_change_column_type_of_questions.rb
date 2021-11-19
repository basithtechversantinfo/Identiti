class ChangeColumnTypeOfQuestions < ActiveRecord::Migration[5.2]
  def change
    change_column :questions, :question_type, 'integer USING CAST(question_type AS integer)'
    change_column :questions, :chart_type, 'integer USING CAST(chart_type AS integer)'
  end
end
