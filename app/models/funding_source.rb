# == Schema Information
#
# Table name: funding_sources
#
#  id         :integer          not null, primary key
#  name       :text(16777215)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FundingSource < ApplicationRecord
  include SharedQueryableMethods

  has_many :funding_sources_sd_meta_data, inverse_of: :funding_source
  has_many :sd_meta_data, through: :funding_sources_sd_meta_data
end
