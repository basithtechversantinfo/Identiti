class AddClonedToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :cloned, :boolean, default: false
  end
end
