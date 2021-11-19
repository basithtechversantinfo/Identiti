class AddMasterIdToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :master_id, :bigint
  end
end
