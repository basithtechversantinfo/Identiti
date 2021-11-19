class AddDisplayTypeToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :display_type, :string
  end
end
