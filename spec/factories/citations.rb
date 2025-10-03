FactoryBot.define do
  factory :citation do
    name { 'Test Citation' }
    citation_type_id { 1 }
    pmid { '123456' }
    abstract { 'Test abstract' }
    # Add other required attributes here
  end
end
