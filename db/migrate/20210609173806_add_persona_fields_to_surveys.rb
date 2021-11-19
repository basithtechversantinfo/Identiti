class AddPersonaFieldsToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :gender, :string
    add_column :surveys, :gender_image_slug, :string
    add_column :surveys, :gender_full_name, :string
  end
end
