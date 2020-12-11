# == Schema Information
#
# Table name: orderings
#
#  id             :integer          not null, primary key
#  orderable_type :string(255)
#  orderable_id   :integer
#  position       :integer
#  deleted_at     :datetime
#  active         :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Ordering < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true

  belongs_to :orderable, polymorphic: true
end
