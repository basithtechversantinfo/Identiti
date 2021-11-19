class AddClonedFromToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :cloned_from, :integer
  end
end
