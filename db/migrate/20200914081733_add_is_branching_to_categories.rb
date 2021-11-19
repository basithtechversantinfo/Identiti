class AddIsBranchingToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :is_branching, :boolean, default: false
  end
end
