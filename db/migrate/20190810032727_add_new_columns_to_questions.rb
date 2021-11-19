class AddNewColumnsToQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :questions, :geographic_type, :integer

    add_column :questions, :star_rating_range, :integer, default: 5
    add_column :questions, :star_rating_shape, :integer, default: 0
    add_column :questions, :star_rating_labels, :integer, default: 0

    add_column :questions, :range_slider_left, :integer, default: 0
    add_column :questions, :range_slider_right, :integer, default: 10
    add_column :questions, :range_slider_step, :integer, default: 1
    add_column :questions, :range_slider_position, :integer, default: 0
  end
end
