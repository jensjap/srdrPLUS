FactoryBot.define do
  factory :key_questions_project do
    association :key_question
    association :project
    pos { 1 }
  end
end
