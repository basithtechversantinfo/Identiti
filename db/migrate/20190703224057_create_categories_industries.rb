class CreateCategoriesIndustries < ActiveRecord::Migration[5.2]
  def change
    create_table :categories_industries do |t|
      t.integer :industry_id
      t.integer :category_id

      t.timestamps
    end
  end
end
