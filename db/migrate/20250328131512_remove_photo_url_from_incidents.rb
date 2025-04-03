class RemovePhotoUrlFromIncidents < ActiveRecord::Migration[7.1]
  def change
    remove_column :incidents, :photo_url, :string
  end
end
