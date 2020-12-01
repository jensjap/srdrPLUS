namespace :ucum_tasks do
  desc "Validate every unit in timepoint_names table with NIH's UCUM unit validity service."
  task validate_all: [:environment] do
    TimepointName.all.each do |tn|
      next if tn.isValidUCUMTested

      url = TimepointName::SERVICE_ADDRESS + CGI.escape(tn.unit)
      begin
        resp = HTTParty.get(url).body
        tn.isValidUCUM = ActiveModel::Type::Boolean.new.cast(resp)
        tn.isValidUCUMTested = true
        tn.save

      rescue Exception => e
        tn.isValidUCUMTested = false
        tn.save

      end
      p tn
    end
  end
end
