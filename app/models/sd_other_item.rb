# == Schema Information
#
# Table name: sd_other_items
#
#  id               :integer          not null, primary key
#  sd_meta_datum_id :integer
#  name             :text(65535)
#  url              :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class SdOtherItem < ApplicationRecord
  belongs_to :sd_meta_datum, inverse_of: :sd_other_items
end
