FactoryBot.define do
  factory :project do
    name { Faker::Movies::HarryPotter.quote }
    description { Faker::Movies::HarryPotter.quote }
    attribution { Faker::Creature::Cat.registry }
    methodology_description { Faker::Movies::HarryPotter.quote }
    prospero { Faker::Number.hexadecimal(12) }
    doi { Faker::Number.hexadecimal(6) }
    notes { Faker::Movies::HarryPotter.book }
    funding_source { Faker::Book.publisher }
    created_at { Time.now }
    updated_at { Time.now }
  end
end
