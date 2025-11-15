FactoryBot.define do
  factory :projects_user do
    association :project
    association :user
  end
end
