class Invitation < ApplicationRecord
  include SharedTokenableMethods

  belongs_to :invitable, polymorphic: true
  belongs_to :role
end
