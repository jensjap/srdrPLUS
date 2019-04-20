task add_screening_option_types: [:environment] do
  names_arr = ['TAG_REQUIRED',
               'NOTE_REQUIRED',
               'REASON_REQUIRED',
               'ONLY_LEAD_TAGS',
               'ONLY_LEAD_REASONS',
               'HIDE_AUTHORS',
               'HIDE_JOURNAL']

  names_arr.each do |name|
    sot = ScreeningOptionType.find_by( name: name )
    if sot.present?
      puts "Screening option type #{name} already present, skipping... "
    else
      ScreeningOptionType.create!( name: name )
      puts "Screening option type #{name} missing, creating... "
    end
  end
end
