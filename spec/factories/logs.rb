FactoryBot.define do
  factory :log do
    association :loggable, factory: :citations_project
    # Add other required attributes here
  end
end
