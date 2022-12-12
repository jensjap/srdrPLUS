# == Schema Information
#
# Table name: orderings
#
#  id             :integer          not null, primary key
#  orderable_type :string(255)
#  orderable_id   :integer
#  position       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Ordering < ApplicationRecord
  belongs_to :orderable, polymorphic: true
end
