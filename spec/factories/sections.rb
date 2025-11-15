FactoryBot.define do
  factory :section do
    sequence(:name) { |n| "Section #{n} #{SecureRandom.hex(4)}" }
    default { false }
  end
end
