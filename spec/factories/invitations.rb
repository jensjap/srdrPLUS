FactoryBot.define do
  factory :invitation do
    invitable { nil }
    enable { false }
    role { nil }
  end
end
