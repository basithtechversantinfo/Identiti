class CreateSurveys < ActiveRecord::Migration[5.2]
  def change
    create_table :surveys do |t|
      t.string :title
      t.string :email_from
      t.string :email_sender
      t.string :email_subject
      t.datetime :delivery_time
      t.datetime :delivery_start_at
      t.datetime :delivery_end_at
      t.integer :group_id

      t.timestamps
    end
  end
end
