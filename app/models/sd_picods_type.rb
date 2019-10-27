# == Schema Information
#
# Table name: sd_picods_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SdPicodsType < ApplicationRecord
  include SharedQueryableMethods

  has_many :sd_picods_sd_picods_types, inverse_of: :sd_picods_type
  has_many :sd_picods, through: :sd_picods_sd_picods_types
end
