FactoryBot.define do
  factory :citation_type do
    name { 'Primary' }
    initialize_with { CitationType.find_or_create_by(name: name) }
  end
end
