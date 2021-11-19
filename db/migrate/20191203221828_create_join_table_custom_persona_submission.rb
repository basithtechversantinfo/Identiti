class CreateJoinTableCustomPersonaSubmission < ActiveRecord::Migration[5.2]
  def change
    create_join_table :custom_personas, :submissions do |t|
      # t.index [:custom_persona_id, :submission_id]
      # t.index [:submission_id, :custom_persona_id]
    end
  end
end
