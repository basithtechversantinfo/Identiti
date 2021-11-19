class CreateCategoriesSurveys < ActiveRecord::Migration[5.2]
  def change
    create_table :categories_surveys do |t|
      t.integer :survey_id
      t.integer :category_id
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
