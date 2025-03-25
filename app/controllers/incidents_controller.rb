class IncidentsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_incident, only: [:show, :destroy, :edit, :update, :confirm, :contest]

  def new
    @incident = Incident.new
    @categories = category_options
  end

  def create
    @incident = current_user.incidents.build(incident_params)
    @categories = category_options

    if @incident.save
      redirect_to my_incidents_incidents_path, notice: "Incident créé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def my_incidents
    @incidents = current_user.incidents.includes(:comments)
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
    @incidents = Incident.all

    # The `geocoded` scope filters only incidents with coordinates
    @markers = @incidents.geocoded.map do |incident|
      {
        lat: incident.latitude,
        lng: incident.longitude,
        info_window_html: render_to_string(partial: "info_window", locals: {incident: incident}),
        marker_html: render_to_string(partial: "marker")
      }
    end
  end

  # POST /incidents or /incidents.json
    # respond_to do |format|
    #   if @incident.save
    #     format.html { redirect_to @incident, notice: "Incident was successfully created." }
    #     format.json { render :show, status: :created, location: @incident }
    #   else
    #     format.html { render :new, status: :unprocessable_entity }
    #     format.json { render json: @incident.errors, status: :unprocessable_entity }
    #   end
    # end

  def show
    @incident = Incident.find(params[:id])

  #  if current_user && current_user.latitude && current_user.longitude
  #    @distance = @incident.distance_to([current_user.latitude, current_user.longitude], :km).roun(1)
  #  end
  end

  def edit
    @categories = category_options
  end

  def update
    if @incident.update(incident_params)
      redirect_to my_incidents_incidents_path, notice: "Incident mis à jour avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def confirm
    create_or_update_vote(true)
  end

  def contest
    create_or_update_vote(false)
  end

  private

  def set_incident
    @incident = Incident.find(params[:id])
  end

  def incident_params
    params.require(:incident).permit(:title, :address, :date, :category, :description, :photo_url, :latitude, :longitude)
  end

  def category_options
    {
      "Attaque à main armée" => "Attaque à main armée",
      "Assassinat" => "Assassinat",
      "Enlèvement" => "Enlèvement",
      "Prise d’otages" => "Prise d’otages",
      "Éboulement" => "Éboulement",
      "Inondation" => "Inondation",
      "Tremblement de terre" => "Tremblement de terre",
      "Vol à l’étalage" => "Vol à l’étalage",
      "Agression" => "Agression",
      "Trafic de drogue" => "Trafic de drogue",
      "Émeute" => "Émeute",
      "Incendie" => "Incendie",
      "Accident de la route" => "Accident de la route",
      "Fraude électorale" => "Fraude électorale",
      "Manifestation violente" => "Manifestation violente",
      "Disparition" => "Disparition",
      "Braquage de voiture" => "Braquage de voiture"
    }
  end

  def create_or_update_vote(vote_value)
    return redirect_to new_user_session_path, alert: "Vous devez être connecté pour voter." unless user_signed_in?

    existing_vote = @incident.votes.find_by(user: current_user)

    if existing_vote
      existing_vote.update(vote: vote_value)
      flash[:notice] = "Votre vote a été mis à jour."
    else
      @incident.votes.create(user: current_user, vote: vote_value)
      flash[:notice] = "Votre vote a été enregistré."
    end

    redirect_to @incident
  rescue ActiveRecord::RecordNotUnique
    flash[:alert] = "Vous avez déjà voté pour cet incident."
    redirect_to @incident
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e.message
    redirect_to @incident
  end

end
