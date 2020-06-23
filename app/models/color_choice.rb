# == Schema Information
#
# Table name: color_choices
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  hex_code   :string(255)
#  rgb_code   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ColorChoice < ApplicationRecord
  has_many :colorings
end
