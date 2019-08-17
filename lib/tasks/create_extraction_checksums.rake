task create_extraction_checksums: [:environment] do
  Extraction.left_joins(:extraction_checksum).where(extraction_checksums: { extraction: nil }).each do |extraction|
    extraction.update_checksum
  end
end
