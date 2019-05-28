namespace :team_type_tasks do
  desc "Adds TeamType seed data"
  task AddSeedNames: :environment do
    TeamType.find_or_create_by(name: 'Citation Screening Team')
    TeamType.find_or_create_by(name: 'Citation Screening Blacklist')
  end

end
