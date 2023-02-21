# == Schema Information
#
# Table name: sd_grey_literature_searches
#
#  id               :integer          not null, primary key
#  sd_meta_datum_id :integer
#  name             :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  position         :integer          default(0)
#

class SdGreyLiteratureSearch < ApplicationRecord
  include SharedOrderableMethods

  before_validation -> { set_ordering_scoped_by(:sd_meta_datum_id) }, on: :create

  belongs_to :sd_meta_datum, inverse_of: :sd_grey_literature_searches

  has_one :ordering, as: :orderable, dependent: :destroy
end
