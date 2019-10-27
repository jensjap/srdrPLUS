# == Schema Information
#
# Table name: approvals
#
#  id              :integer          not null, primary key
#  approvable_type :string(255)
#  approvable_id   :integer
#  user_id         :integer
#  deleted_at      :datetime
#  active          :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Approval < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :approvable, polymorphic: true
  belongs_to :user, inverse_of: :approvals

  validates :approvable, :user, presence: true
end
