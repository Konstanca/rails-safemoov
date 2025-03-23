class AddIndexToIncidents < ActiveRecord::Migration[7.1]
  def change
    add_index :incidents, [:latitude, :longitude]
  end
end
