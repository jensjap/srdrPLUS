json.assigned_user extraction.user,
                   partial: 'api/v2/users/user',
                   as: :user
json.merge! extraction.attributes
