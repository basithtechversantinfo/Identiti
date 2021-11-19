class AddPositionToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :position, :integer, default: 0
  end
end
