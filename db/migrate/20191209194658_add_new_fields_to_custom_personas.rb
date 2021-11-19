class AddNewFieldsToCustomPersonas < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_personas, :gender, :string
    add_column :custom_personas, :gender_image_slug, :string
  end
end
