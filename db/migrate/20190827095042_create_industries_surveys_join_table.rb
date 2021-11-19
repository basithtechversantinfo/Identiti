class CreateIndustriesSurveysJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_table :industries_surveys, id: false do |t|
      t.bigint :industry_id
      t.bigint :survey_id
    end

    add_index :industries_surveys, :industry_id
    add_index :industries_surveys, :survey_id
  end
end
