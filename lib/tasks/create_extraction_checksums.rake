task create_extraction_checksums: [:environment] do
  Extraction.left_joins(:extraction_checksum).where(extraction_checksums: { extraction: nil }).each do |extraction|
    puts "Creating checksum for extraction: #{extraction.id.to_s}"
    ExtractionChecksum.create! extraction: extraction, is_stale: true
  end
end
