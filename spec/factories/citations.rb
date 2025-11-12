FactoryBot.define do
  factory :citation do
    sequence(:name) { |n| "Test Citation #{n} #{SecureRandom.hex(4)}" }
    association :citation_type
    sequence(:pmid) { |n| "#{123456 + n}" }
    abstract { 'Test abstract' }
    # Add other required attributes here
  end
end
