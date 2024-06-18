json.array! @memberships do |membership|
  json.username membership.user.username
  json.user_id membership.user.id
  json.room_id @room.id
  json.membership_id membership.id
  json.projects_user membership.room.project&.users&.include?(membership.user) || false
end
