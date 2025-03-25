class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create]
  before_action :set_incident, only: [:create]

  def create
    @comment = @incident.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to incident_path(@incident), notice: "Commentaire ajouté avec succès."
    else
      redirect_to incident_path(@incident), alert: "Erreur lors de l'ajout du commentaire."
    end
  end

  private

  def set_incident
    @incident = Incident.find(params[:incident_id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
