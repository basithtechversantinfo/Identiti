class AddNonEmailLinkToSurveys < ActiveRecord::Migration[5.2]
  def change
    add_column :surveys, :non_email_link, :boolean, default: false
  end
end
