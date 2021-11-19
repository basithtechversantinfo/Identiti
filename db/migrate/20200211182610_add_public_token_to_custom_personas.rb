class AddPublicTokenToCustomPersonas < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_personas, :public_token, :string
  end
end
