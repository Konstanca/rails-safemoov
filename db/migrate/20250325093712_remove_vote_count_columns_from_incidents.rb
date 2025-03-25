class RemoveVoteCountColumnsFromIncidents < ActiveRecord::Migration[7.1]
  def change
    remove_column :incidents, :vote_count_plus, :integer
    remove_column :incidents, :vote_count_minus, :integer
  end
end
