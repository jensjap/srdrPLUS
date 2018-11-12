json.pagination do
  json.more @more
end

json.results do
  if not @projects_user_tags.empty?
    json.child! do
      json.text "projects_user_tags"
      json.children do
        json.array!( @projects_user_tags ) do | tags |
          json.id tags.id
          json.text tags.name
        end
      end
    end
  end
  if not @user_tags.empty?
    json.child! do
      json.text "user_tags"
      json.children do
        json.array!( @user_tags ) do | tags |
          json.id tags.id
          json.text tags.name
        end
      end
    end
  end
  if not @lead_tags.empty?
    json.child! do
      json.text "project_lead_tags"
      json.children do
        json.array!( @lead_tags ) do | tags |
          json.id tags.id
          json.text tags.name
        end
      end
    end
  end
end

