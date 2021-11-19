class CreateAccountSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :account_settings do |t|
      t.references :account, foreign_key: true
      t.string :no_of_employees
      t.integer :industry_id
      t.integer :user_id

      t.timestamps
    end
  end
end
