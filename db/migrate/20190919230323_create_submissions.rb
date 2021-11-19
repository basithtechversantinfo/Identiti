class CreateSubmissions < ActiveRecord::Migration[5.2]
  def change
    create_table :submissions do |t|
      t.references :survey, foreign_key: true
      t.references :recipient, foreign_key: true

      t.timestamps
    end

    add_column :submissions, :status, :integer, default: 0

    add_column :submissions, :total_time, :bigint, default: 0

    add_column :submissions, :submission_category_time_spent, :jsonb
    add_index :submissions, :submission_category_time_spent, using: :gin

    add_column :submissions, :submission_question_time_spent, :jsonb
    add_index :submissions, :submission_question_time_spent, using: :gin

    add_column :submissions, :data_json, :jsonb
    add_index :submissions, :data_json, using: :gin

  end
end
