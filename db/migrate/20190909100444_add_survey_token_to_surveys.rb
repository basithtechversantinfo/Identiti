class AddSurveyTokenToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :survey_token, :string
  end
end
