class UserDetail < ApplicationRecord
  belongs_to :user
  belongs_to :organization
  belongs_to :title
end
