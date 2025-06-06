class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create]
  before_action :set_incident, only: [:create]

  def create
    @comment = @incident.comments.build(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        @incident = Incident.includes(comments: :user).find(@incident.id)
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("comments_list", partial: "incidents/comments_list", locals: { incident: @incident }),
            turbo_stream.replace("comment_form", partial: "incidents/comment_form", locals: { incident: @incident, comment: Comment.new })
          ]
        end
        format.html { redirect_to incident_path(@incident), notice: "Commentaire ajouté avec succès." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("comment_form", partial: "incidents/comment_form", locals: { incident: @incident, comment: @comment }) }
        format.html { redirect_to incident_path(@incident), alert: "Erreur lors de l'ajout du commentaire." }
      end
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
