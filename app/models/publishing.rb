# == Schema Information
#
# Table name: publishings
#
#  id               :integer          not null, primary key
#  publishable_type :string(255)
#  publishable_id   :integer
#  user_id          :integer
#  deleted_at       :datetime
#  active           :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Publishing < ApplicationRecord
  include SharedApprovableMethods
  include SharedParanoiaMethods

  scope :unapproved, -> () { left_outer_joins(:approval).where(approvals: { id: nil }) }
  scope :approved, -> () { joins(:approval) }

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :publishable, polymorphic: true
  belongs_to :user, inverse_of: :publishings

  has_one :approval, as: :approvable, dependent: :destroy

  SD_META_DATUM = 'SdMetaDatum'.freeze

  def name_of_pub_type
    if publishable_type == SD_META_DATUM
      "SR360"
    end
  end
end
