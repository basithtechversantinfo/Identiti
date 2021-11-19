class AddArchivedToLists < ActiveRecord::Migration[5.2]
  def change
    add_column :lists, :archived, :boolean, default: false
  end
end
