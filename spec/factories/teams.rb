FactoryBot.define do
  factory :team do
    team_type { nil }
    project { nil }
    enabled { false }
    name { "MyString" }
    deleted_at { "2019-05-27 18:00:07" }
  end
end
