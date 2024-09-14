class HelpChannel < ApplicationCable::Channel
  def subscribed
    # TODO: authorize
    message_keys = params[:messageKeys]
    project = Project.find_by(id: message_keys[:project])
    citations_project = CitationsProject.find_by(id: message_keys[:citations_project])
    efps = ExtractionFormsProjectsSection.find_by(id: message_keys[:efps])
    extraction = Extraction.find_by(id: message_keys[:extraction])

    stream_from "project-#{project.id}" if project
    stream_from "citations_project-#{citations_project.id}-efps-#{efps&.id}" if citations_project
    stream_from "extraction-#{extraction.id}" if extraction
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
