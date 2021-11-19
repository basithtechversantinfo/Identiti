class AddDisplayTypesToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :persona_summary_display_type, :integer
  end
end
