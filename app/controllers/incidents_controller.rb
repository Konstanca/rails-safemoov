class IncidentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_incident, only: [:destroy]

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

  def update
  end

  private

  def set_incident
    @incident = Incident.find(params[:id])
  end

  def incident_params
    params.require(:incident).permit(:title, :address, :date, :category, :description, :photo_url, :latitude, :longitude)
  end
end
