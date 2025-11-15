FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    password { 'password' }
    confirmed_at { Time.current }
    association :user_type, factory: :user_type
  end
end
