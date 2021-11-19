class AddGenderAndImageSlugToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :gender, :string
    add_column :submissions, :gender_image_slug, :string
  end
end
