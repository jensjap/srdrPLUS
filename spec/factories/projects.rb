FactoryBot.define do
  factory :project do
    sequence(:name) { |n| "Test Project #{n} #{SecureRandom.hex(4)}" }
    create_empty { true }
  end
end
