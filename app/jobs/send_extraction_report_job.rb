class SendExtractionReportJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    Log.includes(loggable: [:assignor, { citations_project: :citation }])
       .where(loggable_type: 'Extraction')
       .where(created_at: 1445.minutes.ago..5.minutes.from_now)
       .group_by { |log| log.loggable.assignor }
       .each do |assignor, logs|
      next unless assignor

      log_messages = logs.map do |log|
        extraction = log.loggable
        citation = extraction.citations_project.citation
        "Extraction ID: #{extraction.id} (#{citation.name}) was set to '#{log.description}'"
      end

      SendExtractionReportMailer.send_extraction_report(assignor.email, assignor.handle, log_messages).deliver_later
    end
  end
end
