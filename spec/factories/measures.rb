FactoryBot.define do
  factory :measure do
    sequence(:name) { |n| "Measure #{n}" }

    trait :mean do
      name { 'Mean' }
    end

    trait :median do
      name { 'Median' }
    end

    trait :standard_deviation do
      name { 'Standard Deviation' }
    end

    trait :total_n_analyzed do
      name { 'Total N Analyzed' }
    end

    trait :events do
      name { 'Events' }
    end

    trait :percentage do
      name { 'Percentage' }
    end

    trait :adjusted do
      name { 'Adjusted Mean' }
    end
  end
end
