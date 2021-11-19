class AddSurveyTypeToSurveys < ActiveRecord::Migration[5.2]
  def change
  	add_column :surveys, :survey_type, :integer, default: 0
  end
end
