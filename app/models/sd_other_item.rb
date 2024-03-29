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
#  pos              :integer          default(999999)
#

class SdOtherItem < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :sd_meta_datum, inverse_of: :sd_other_items

  delegate :project, to: :sd_meta_datum
end
