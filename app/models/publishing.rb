# == Schema Information
#
# Table name: publishings
#
#  id               :integer          not null, primary key
#  publishable_type :string(255)
#  publishable_id   :integer
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Publishing < ApplicationRecord
  include SharedApprovableMethods

  attr_accessor :terms_agreement, :guidelines_agreement

  scope :unapproved, -> { left_outer_joins(:approval).where(approvals: { id: nil }) }
  scope :approved, -> { joins(:approval) }

  belongs_to :publishable, polymorphic: true
  belongs_to :user, inverse_of: :publishings

  has_one :approval, as: :approvable, dependent: :destroy

  def project
    if project?
      publishable
    elsif sd_meta_datum?
      publishable.project
    end
  end

  def project?
    publishable_type == Project.to_s
  end

  def sd_meta_datum?
    publishable_type == SdMetaDatum.to_s
  end

  def name_of_pub_type
    if publishable_type == SdMetaDatum.to_s
      'SR360'
    elsif publishable_type == Project.to_s
      'Project'
    end
  end
end
