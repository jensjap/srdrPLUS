json.pagination do
  json.more @more
end

json.results do
  json.array!(@users) do |user|
    json.id user.id
    json.text "#{sanitize(user.profile.username)} (#{user.email})"
  end
end

