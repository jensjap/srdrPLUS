class ExtractionReportJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    Extraction
      .includes(:logs, { citations_project: :citation })
      .where.not(assignor: nil)
      .where(logs: { loggable_type: 'Extraction', created_at: 1445.minutes.ago..5.minutes.from_now })
      .group_by(&:assignor)
      .each do |assignor, extractions|
      log_messages = []
      extractions.each do |extraction|
        next unless extraction.logs.present?

        newest_log = extraction.logs.max_by(&:id)
        log_messages << "Extraction ID: #{extraction.id} (#{extraction.citations_project.citation.name}) was set to '#{newest_log.description}'"
      end

      ExtractionReportMailer.send_extraction_report(assignor.email, assignor.handle, log_messages).deliver_later
    end
  end
end
