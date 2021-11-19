class AddSavedBlockToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :saved_block, :boolean, default: false
  end
end
