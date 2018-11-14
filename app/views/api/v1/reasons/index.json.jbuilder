json.results do
  if not @projects_user_reasons.empty?
    json.child! do
      json.text "projects_user_reasons"
      json.children do
        json.array!( @projects_user_reasons ) do | reason |
          json.id reason.id
          json.text reason.name
        end
      end
    end
  end
  if not @lead_reasons.empty?
    json.child! do
      json.text "project_lead_reasons"
      json.children do
        json.array!( @lead_reasons ) do | reason |
          json.id reason.id
          json.text reason.name
        end
      end
    end
  end
end

