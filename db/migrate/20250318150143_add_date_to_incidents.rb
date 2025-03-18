class AddDateToIncidents < ActiveRecord::Migration[7.1]
  def change
    add_column :incidents, :date, :datetime
  end
end
