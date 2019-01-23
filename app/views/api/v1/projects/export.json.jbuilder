json.project do
  json.id @project.id
  json.name @project.name
  json.description @project.description
  json.users do  
    json.array!( @project.projects_users ) do |pu|
      json.set! pu.id do
        json.email pu.user.email
        json.profile do
          json.username pu.user.profile.username
          json.first_name pu.user.profile.first_name
          json.middle_name pu.user.profile.middle_name
          json.last_name pu.user.profile.last_name
          json.organization do
            json.id pu.user.profile.organization.id
            json.name pu.user.profile.organization.name
          end
        end
        json.roles do
          json.array!( pu.roles ) do |r|
            json.set! r.id do
              json.name r.name
            end
          end
        end

        json.term_groups do
          json.array! pu.term_groups do |tg|
            json.set! tg.id do
              json.name tg.name
              json.terms do 
                json.array! tg.terms do |t|
                  json.set t.id do
                    json.name t.name
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
