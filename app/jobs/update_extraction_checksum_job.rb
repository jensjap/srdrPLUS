class UpdateExtractionChecksumJob < ApplicationJob
  queue_as :low

  rescue_from(StandardError) do |exception|
    # Do something with the exception
    byebug
  end

  def perform(*args)
    created_at = args.first
    extraction = Extraction.includes(:extraction_checksum).find args.second
    
    if extraction.extraction_checksum.updated_at.to_i < created_at
      extraction.update_checksum
    end
  end
end
