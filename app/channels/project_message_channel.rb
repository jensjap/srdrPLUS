class ProjectMessageChannel < ApplicationCable::Channel
  def subscribed
    # TODO: authorize
    project = Project.find(params[:project_id])
    stream_from "project_message-#{project.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
