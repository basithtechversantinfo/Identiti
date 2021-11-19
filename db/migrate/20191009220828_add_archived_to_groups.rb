class AddArchivedToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :archived, :boolean, default: false
  end
end
