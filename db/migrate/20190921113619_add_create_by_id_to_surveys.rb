class AddCreateByIdToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :created_by_id, :integer
  end
end
