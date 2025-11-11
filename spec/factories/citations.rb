FactoryBot.define do
  factory :citation do
    name { 'Test Citation' }
    association :citation_type
    pmid { '123456' }
    abstract { 'Test abstract' }
    # Add other required attributes here
  end
end
