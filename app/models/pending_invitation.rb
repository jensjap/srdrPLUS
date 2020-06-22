# == Schema Information
#
# Table name: pending_invitations
#
#  id            :bigint           not null, primary key
#  invitation_id :bigint
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class PendingInvitation < ApplicationRecord
  include SharedApprovableMethods

  belongs_to :invitation
  belongs_to :user

  has_one :approval, as: :approvable, dependent: :destroy
end
