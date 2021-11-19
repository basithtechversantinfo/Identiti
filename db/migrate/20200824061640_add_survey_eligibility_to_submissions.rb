class AddSurveyEligibilityToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :survey_eligibility, :integer, default: 0
  end
end
