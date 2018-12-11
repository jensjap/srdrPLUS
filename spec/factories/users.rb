FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@test.com" }
    password { 'password' }
    confirmed_at { Time.now }
    user_type { FactoryBot.create(:user_type) }
  end
end
