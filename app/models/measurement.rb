# == Schema Information
#
# Table name: measurements
#
#  id                     :integer          not null, primary key
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  value                  :string(255)
#  comparisons_measure_id :integer
#

class Measurement < ApplicationRecord
  belongs_to :comparisons_measure, required: false 
  has_one :measure, through: :comparisons_measure
end
