class CreateIndustries < ActiveRecord::Migration[5.2]
  def change
    create_table :industries do |t|
      t.string :title
      t.text :description
      t.string :slug_id

      t.timestamps
    end
  end
end
