json.results do
  json.array!(@projects_users_roles) do |projects_users_role|
    json.id projects_users_role.id
    json.text projects_users_role.handle
  end
end


