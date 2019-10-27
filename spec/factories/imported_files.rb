FactoryBot.define do
  factory :imported_file do
    projects_user { nil }
    file_type { nil }
    import_type { nil }
    content { "" }
    section { nil }
  end
end
