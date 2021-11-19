class AddPublicTokenToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :public_token, :string
  end
end
