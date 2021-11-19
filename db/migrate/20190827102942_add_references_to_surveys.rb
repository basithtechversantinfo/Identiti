class AddReferencesToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_reference :surveys, :template_theme, foreign_key: true
  end
end
