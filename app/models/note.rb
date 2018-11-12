class Note < ApplicationRecord
  belongs_to :projects_users_role
  belongs_to :notable, polymorphic: true

end
