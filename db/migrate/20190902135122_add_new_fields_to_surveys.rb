class AddNewFieldsToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :thank_you_page, :text
    add_column :surveys, :welcome_page, :text
  end
end
