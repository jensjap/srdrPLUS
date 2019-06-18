json.extract! invitation, :id, :invitable_id, :invitable_type, :enable, :role_id, :created_at, :updated_at
json.url invitation_url(invitation, format: :json)
