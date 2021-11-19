class AddBlockRelationTypeToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :block_relation_type, :string
  end
end
