class AddSurveySentAtToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :survey_sent_at, :datetime
  end
end
