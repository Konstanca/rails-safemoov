class CreateIncidents < ActiveRecord::Migration[7.1]
  def change
    create_table :incidents do |t|
      t.string :title
      t.text :description
      t.string :address
      t.boolean :status
      t.string :category
      t.references :user, null: false, foreign_key: true
      t.string :photo_url
      t.float :latitude
      t.float :longitude
      t.integer :vote_count_plus
      t.integer :vote_count_minus

      t.timestamps
    end
  end
end
