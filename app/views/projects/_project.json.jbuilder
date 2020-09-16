json.extract! project, :id, :name, :description, :attribution, :authors_of_report, :methodology_description, :prospero, :doi, :notes, :funding_source, :created_at, :updated_at
json.url project_url(project, format: :json)
