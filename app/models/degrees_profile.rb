# == Schema Information
#
# Table name: degrees_profiles
#
#  id         :integer          not null, primary key
#  degree_id  :integer
#  profile_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DegreesProfile < ApplicationRecord
  belongs_to :degree,  inverse_of: :degrees_profiles
  belongs_to :profile, inverse_of: :degrees_profiles

  validates :degree_id, :profile_id, presence: true

  accepts_nested_attributes_for :degree, reject_if: :all_blank
end
