class IncidentsController < ApplicationController

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
  def create
    @incident = Incident.new(incident_params)

    if @incident.save
      redirect_to @incident, notice: "Incident créé avec succès"
    else
      render :new, status: :unprocessable_entity
    end
    # respond_to do |format|
    #   if @incident.save
    #     format.html { redirect_to @incident, notice: "Incident was successfully created." }
    #     format.json { render :show, status: :created, location: @incident }
    #   else
    #     format.html { render :new, status: :unprocessable_entity }
    #     format.json { render json: @incident.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  def show
  end

  def update
  end

  def destroy
  end

  def new
  end


  private

  # Use callbacks to share common setup or constraints between actions.
  def set_incident
    @incident = Incident.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def incident_params
    params.require(:incident).permit(:title, :description, :address, :status, :category)
  end

end
