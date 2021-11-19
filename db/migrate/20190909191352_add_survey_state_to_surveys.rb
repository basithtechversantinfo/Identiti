class AddSurveyStateToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :survey_state, :integer, default: 0
  end
end
