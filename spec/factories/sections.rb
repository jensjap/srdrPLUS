FactoryBot.define do
  factory :section do
    sequence(:name) { |n| "Section #{n}" }
    default { false }
  end
end
