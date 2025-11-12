FactoryBot.define do
  factory :record do
    association :recordable, factory: :tps_arms_rssm
    sequence(:name) { |n| "#{n}.0" }
  end
end
