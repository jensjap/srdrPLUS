# == Schema Information
#
# Table name: funding_sources_sd_meta_data
#
#  id                :integer          not null, primary key
#  funding_source_id :integer
#  sd_meta_datum_id  :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class FundingSourcesSdMetaDatum < ApplicationRecord
  belongs_to :funding_source, inverse_of: :funding_sources_sd_meta_data
  belongs_to :sd_meta_datum, inverse_of: :funding_sources_sd_meta_data
end
