class AddImageSlugToRecipients < ActiveRecord::Migration[5.2]
  def change
    add_column :recipients, :image_slug, :string, default: 'men-1'
  end
end
