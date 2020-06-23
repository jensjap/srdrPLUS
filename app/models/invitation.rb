# == Schema Information
#
# Table name: invitations
#
#  id             :bigint           not null, primary key
#  role_id        :integer
#  invitable_type :string(255)
#  invitable_id   :bigint
#  enabled        :boolean          default(FALSE)
#  token          :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Invitation < ApplicationRecord
  include SharedApprovableMethods
  include SharedTokenableMethods

  attr_accessor :requires_approval

  before_save :generate_token

  belongs_to :invitable, polymorphic: true
  belongs_to :role

  has_one :approval, as: :approvable, dependent: :destroy

  def generate_url
    'localhost:3000/invitations/join/' + token.to_s
  end
end
