class ProjectMessageChannel < ApplicationCable::Channel
  def subscribed
    project = Project.find(params[:project_id])
    stream_from "project_message-#{project.id}" if project && HelpChannelPolicy.new(current_user,
                                                                                    project).subscribed?
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
