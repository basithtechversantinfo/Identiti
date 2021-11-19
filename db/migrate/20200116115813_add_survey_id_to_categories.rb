class AddSurveyIdToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :survey_id, :bigint
  end
end
