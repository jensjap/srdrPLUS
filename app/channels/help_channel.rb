class HelpChannel < ApplicationCable::Channel
  def subscribed
    message_keys = params[:messageKeys]
    project = Project.find_by(id: message_keys[:project])
    citations_project = CitationsProject.find_by(id: message_keys[:citations_project])
    extraction = Extraction.find_by(id: message_keys[:extraction])

    stream_from "project-#{project.id}" if project && MessagePolicy.new(current_user,
                                                                        citations_project.project).subscribed?
    stream_from "citations_project-#{citations_project.id}" if citations_project && MessagePolicy.new(
      current_user, citations_project.project
    ).subscribed?
    stream_from "extraction-#{extraction.id}" if extraction && MessagePolicy.new(current_user,
                                                                                 extraction.project).subscribed?
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
