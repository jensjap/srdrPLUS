json.results do
  if not @projects_user_reasons.empty?
    json.projects_user_reasons do
      json.array!( @projects_user_reasons ) do | reason |
        json.id reason.id
        json.text reason.name
      end
    end
  end
  if not @lead_reasons.empty?
    json.project_lead_reasons do
      json.array!( @lead_reasons ) do | reason |
        json.id reason.id
        json.text reason.name
      end
    end
  end
end

