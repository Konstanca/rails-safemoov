# app/controllers/alerts_controller.rb
class AlertsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_alert, only: [:edit, :update, :destroy]

  def index
    @alerts = current_user.alerts
  end

  def new
    @alert = current_user.alerts.build
  end

  def create
    @alert = current_user.alerts.build(alert_params)
    if @alert.save
      redirect_to alerts_path, notice: "Alerte créée avec succès !"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @alert.update(alert_params)
      redirect_to alerts_path, notice: "Alerte mise à jour avec succès !"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @alert.user == current_user
      @alert.destroy!
      redirect_to alerts_path, notice: "Alerte supprimée avec succès !"
    else
      redirect_to alerts_path, alert: "Action non autorisée."
    end
  end

  private

  def set_alert
    @alert = Alert.find(params[:id])
  end

  def alert_params
    params.require(:alert).permit(:address, :radius)
  end
end
