namespace :statuses do
  task add_statuses: [:environment] do
    ['Draft', 'Completed'].each do |status_name|
      status = Status.find_by(name: status_name)
      if status.present?
        puts "#{ status_name } already present, skipping... "
      else
        Status.create!(name: status_name)
        puts "#{ status_name } missing, creating... "
      end
    end
  end

  task add_draft_status_to_eefps: [:environment] do
    ExtractionsExtractionFormsProjectsSection.left_joins(:statusing).where(statusings: { statusable_id: nil }).each do |eefps|
      puts "Creating draft status for eefps: #{eefps.id.to_s}"
      eefps.create_statusing status: Status.find_by!(name: 'Draft')
    end
  end
end
