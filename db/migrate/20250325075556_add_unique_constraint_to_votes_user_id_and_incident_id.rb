class AddUniqueConstraintToVotesUserIdAndIncidentId < ActiveRecord::Migration[7.1]
  def change
    add_index :votes, [:user_id, :incident_id], unique: true
  end
end
