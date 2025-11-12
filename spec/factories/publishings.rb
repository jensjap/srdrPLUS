FactoryBot.define do
  factory :publishing do
    association :publishable, factory: :project
    association :user
  end
end
