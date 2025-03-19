class StatisticsController < ApplicationController
  def local
    @incident = Incident.find(params[:incident_id])
    @radius = params[:radius]&.to_i || 10
    @months = params[:months]&.to_i || 3
    @stats = Statistic.local_statistics(@incident, radius: @radius, months: @months)
    @trends = Statistic.local_trends(@incident, radius: @radius)

    respond_to do |format|
      format.html
      format.json { render json: { stats: @stats, trends: @trends } }
    end
  end
end
