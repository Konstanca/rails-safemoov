class AddRadiusToAlerts < ActiveRecord::Migration[7.1]
  def change
    add_column :alerts, :radius, :float, null: false, default: 5.0 # Par défaut 5 km, ajuste si besoin
  end
end
