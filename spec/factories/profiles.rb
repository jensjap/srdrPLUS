FactoryBot.define do
  factory :profile do
    user { nil }  # Don't automatically create user - let specs handle it
    association :organization
    sequence(:username) { |n| "user#{n}" }
    first_name { 'John' }
    middle_name { 'Q' }
    last_name { 'Doe' }

    # Trait for when you want a profile with a user
    trait :with_user do
      association :user
    end
  end
end
