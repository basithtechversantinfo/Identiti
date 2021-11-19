class AddShowDescriptionsToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :show_descriptions, :boolean, default: false
  end
end
