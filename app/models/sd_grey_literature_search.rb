# == Schema Information
#
# Table name: sd_grey_literature_searches
#
#  id               :integer          not null, primary key
#  sd_meta_datum_id :integer
#  name             :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class SdGreyLiteratureSearch < ApplicationRecord
  belongs_to :sd_meta_datum, inverse_of: :sd_grey_literature_searches
end
