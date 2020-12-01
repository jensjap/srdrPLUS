# == Schema Information
#
# Table name: suggestions
#
#  id               :integer          not null, primary key
#  suggestable_type :string(255)
#  suggestable_id   :integer
#  user_id          :integer
#  deleted_at       :datetime
#  active           :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Suggestion < ApplicationRecord
  include SharedApprovableMethods
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true

  belongs_to :suggestable, polymorphic: true
  belongs_to :user, inverse_of: :suggestions

  has_one :approval, as: :approvable, dependent: :destroy

  validates :suggestable, :user, presence: true
end
