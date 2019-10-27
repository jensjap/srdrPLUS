# == Schema Information
#
# Table name: sd_picods_sd_picods_types
#
#  id                :integer          not null, primary key
#  sd_picod_id       :integer
#  sd_picods_type_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class SdPicodsSdPicodsType < ApplicationRecord
  belongs_to :sd_picod, inverse_of: :sd_picods_sd_picods_types
  belongs_to :sd_picods_type, inverse_of: :sd_picods_sd_picods_types
end
