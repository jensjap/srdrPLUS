json.merge! project.attributes.reject { |k, v| ['created_at', 'updated_at'].include? k }
json.published_at project.publishing.created_at
json.url api_v2_project_url(project, format: :json)
json.is_public project.public?
