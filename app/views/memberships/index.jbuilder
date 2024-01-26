json.array! @users do |user|
  json.username user.username
  json.user_id user.id
  json.room_id @room.id
end
