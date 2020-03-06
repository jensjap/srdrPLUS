class UpdateExtractionChecksumsJob < ApplicationJob
  queue_as :low

  rescue_from(StandardError) do |exception|
    # Do something with the exception
    puts exception.message
  end

  def perform(*args)
    ExtractionChecksum.where(is_stale: true).each do |extraction_checksum|
      extraction_checksum.update_hexdigest
    end
  end
end
