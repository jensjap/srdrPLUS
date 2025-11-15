FactoryBot.define do
  factory :user_type do
    user_type { 'Member' }
    initialize_with { UserType.find_or_create_by(user_type: user_type) }
  end
end
