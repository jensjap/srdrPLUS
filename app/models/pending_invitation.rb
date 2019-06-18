class PendingInvitation < ApplicationRecord
  include SharedApprovableMethods

  belongs_to :invitation
  belongs_to :user

  has_one :approval, as: :approvable, dependent: :destroy
end
