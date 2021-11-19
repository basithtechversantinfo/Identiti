class AddShowBlockNameToSurveys < ActiveRecord::Migration[5.2]
  def change
  	add_column :surveys, :show_block_name, :boolean, default: false
  end
end
