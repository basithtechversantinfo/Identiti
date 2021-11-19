class AddGetSharableLinkToSurveys < ActiveRecord::Migration[5.2]
  def up
    add_column :surveys, :get_sharable_link, :boolean
  end

  def down
    remove_column :surveys, :get_sharable_link, :boolean
  end
end
