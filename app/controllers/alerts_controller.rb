# app/controllers/alerts_controller.rb
class AlertsController < ApplicationController
  before_action :authenticate_user!

  def new
    @alert = current_user.alerts.build
  end

  def create
    @alert = current_user.alerts.build(alert_params)
    if @alert.save
      redirect_to root_path, notice: "Alerte créée avec succès !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def alert_params
    params.require(:alert).permit(:address, :radius)
  end
end
