class AddAccountIdToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :account_id, :integer
    add_index :categories, :account_id
  end
end
