class HelpChannel < ApplicationCable::Channel
  def subscribed
    # TODO: authorize
    message_keys = params[:messageKeys]
    project = Project.find(message_keys[:project])
    citations_project = CitationsProject.find(message_keys[:citations_project])
    efps = ExtractionFormsProjectsSection.find_by(id: message_keys[:efps])
    extraction = Extraction.find(message_keys[:extraction])

    stream_from "project-#{project.id}"
    stream_from "citations_project-#{citations_project.id}-efps-#{efps&.id}"
    stream_from "extraction-#{extraction.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
