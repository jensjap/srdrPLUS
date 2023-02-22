# == Schema Information
#
# Table name: sd_grey_literature_searches
#
#  id               :integer          not null, primary key
#  sd_meta_datum_id :integer
#  name             :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  position         :integer          default(999999)
#

class SdGreyLiteratureSearch < ApplicationRecord
  default_scope { order(:position) }

  belongs_to :sd_meta_datum, inverse_of: :sd_grey_literature_searches
end
