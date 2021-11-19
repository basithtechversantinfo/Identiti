class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :invitation_code
      t.integer :role
      t.integer :active, default: 0
      t.references :account, foreign_key: true

      t.timestamps
    end
  end
end
