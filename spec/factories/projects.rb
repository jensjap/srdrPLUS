FactoryBot.define do
  factory :project do
    name { Faker::HarryPotter.quote }
    description { Faker::HarryPotter.quote }
    attribution { Faker::Cat.registry }
    methodology_description { Faker::HarryPotter.quote }
    prospero { Faker::Number.hexadecimal(12) }
    doi { Faker::Number.hexadecimal(6) }
    notes { Faker::HarryPotter.book }
    funding_source { Faker::Book.publisher }
    created_at { Time.now }
    updated_at { Time.now }
  end
end
