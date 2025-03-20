class IncidentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_incident, only: [:destroy, :edit, :update]

  def new
    @incident = Incident.new
  end

  def create
    @incident = current_user.incidents.build(incident_params)

    if @incident.save
      redirect_to incidents_my_incidents_path, notice: "Incident créé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def my_incidents
    @incidents = current_user.incidents
  end

  def destroy
    if @incident.user == current_user
      @incident.destroy
      redirect_to incidents_my_incidents_path, notice: "Incident supprimé."
    else
      redirect_to incidents_my_incidents_path, alert: "Action non autorisée."
    end
  end

  def index
  end

  def show
  end

  def edit
    @incident
  end

  def update
    if @incident.update(incident_params)
      redirect_to incidents_my_incidents_path, notice: "Incident mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_incident
    @incident = Incident.find(params[:id])
  end

  def incident_params
    params.require(:incident).permit(:title, :address, :date, :category, :description, :photo_url, :latitude, :longitude)
  end
end
