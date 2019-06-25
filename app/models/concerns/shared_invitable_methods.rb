module SharedInvitableMethods
  extend ActiveSupport::Concern

  included do
    has_many :invitations, as: :invitable
    has_many :roles, through: :invitations

    accepts_nested_attributes_for :invitations, allow_destroy: true
  end
end
