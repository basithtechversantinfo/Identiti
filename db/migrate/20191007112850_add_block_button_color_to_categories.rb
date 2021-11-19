class AddBlockButtonColorToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :block_button_color, :string, default: '#26a69a'
  end
end
