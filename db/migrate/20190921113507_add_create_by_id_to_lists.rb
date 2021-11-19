class AddCreateByIdToLists < ActiveRecord::Migration[5.2]
  def change
    add_column :lists, :created_by_id, :integer
  end
end
