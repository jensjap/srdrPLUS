task add_export_types: [:environment] do
  # Export Types
  export_type_arr = [{ name: '.xlsx' }, { name: 'Google Sheets' }]

  export_type_arr.each do |export_type_hash|
    export_type = ExportType.find_by(export_type_hash)
    if export_type.present?
      puts "#{export_type_hash[:name]} already present, skipping... "
    else
      ExportType.create!(export_type_hash)
      puts "#{export_type_hash[:name]} missing, creating... "
    end
  end
end
