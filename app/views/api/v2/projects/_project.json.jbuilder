json.merge! project.attributes
json.url api_v2_project_url(project, format: :json)
json.is_public project.public?
