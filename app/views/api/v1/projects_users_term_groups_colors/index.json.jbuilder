json.projects_users_term_groups_colors do
  json.array!(@projects_users_term_groups_colors) do |putgc|
    json.id putgc.id
    json.projects_user do
      json.id putgc.projects_user.id
    end
    json.term_groups_color do
      json.id putgc.term_groups_color.id
      json.term_group do
        json.id putgc.term_groups_color.term_group.id
        json.name CGI.escapeHTML(putgc.term_groups_color.term_group.name)
      end
      json.color do
        json.id putgc.term_groups_color.color.id
        json.name CGI.escapeHTML(putgc.term_groups_color.color.name)
        json.hex_code CGI.escapeHTML(putgc.term_groups_color.color.hex_code)
      end
    end
  end
end
