class Tagging < ApplicationRecord
  belongs_to :projects_users_role
  belongs_to :tag
  belongs_to :taggable, polymorphic: true
end
