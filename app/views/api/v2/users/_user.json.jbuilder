profile = user.profile
roles   = ProjectsUser.find_by(project: @project, user: user).roles.map(&:name)

json.id user.id
json.email user.email
json.username profile.username
json.first_name profile.first_name
json.middle_name profile.middle_name
json.last_name profile.last_name
json.roles roles
