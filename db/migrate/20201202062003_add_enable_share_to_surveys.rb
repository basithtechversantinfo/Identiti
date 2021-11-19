class AddEnableShareToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :enable_share, :boolean, default: true
  end
end
