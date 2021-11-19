class AddColumnDataToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :data_json, :jsonb, default: nil
    add_index :questions, :data_json, using: :gin
  end
end
