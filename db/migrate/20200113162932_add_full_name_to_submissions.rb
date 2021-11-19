class AddFullNameToSubmissions < ActiveRecord::Migration[5.2]
  def change
    add_column :submissions, :full_name, :string
  end
end
