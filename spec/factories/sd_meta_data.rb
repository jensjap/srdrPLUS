FactoryBot.define do
  factory :sd_meta_datum do
    association :project
    report_title { 'Test SD Meta Data' }
    state { 'DRAFT' }
  end
end
