class CreateJoinTableForListsSurveys < ActiveRecord::Migration[5.2]
  def change
    create_table :lists_surveys, id: false do |t|
      t.bigint :list_id
      t.bigint :survey_id
    end

    add_index :lists_surveys, :list_id
    add_index :lists_surveys, :survey_id
  end
end
