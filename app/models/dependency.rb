# == Schema Information
#
# Table name: dependencies
#
#  id                   :integer          not null, primary key
#  dependable_type      :string(255)
#  dependable_id        :integer
#  prerequisitable_type :string(255)
#  prerequisitable_id   :integer
#  deleted_at           :datetime
#  active               :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Dependency < ApplicationRecord
  belongs_to :dependable,      polymorphic: true
  belongs_to :prerequisitable, polymorphic: true
end
