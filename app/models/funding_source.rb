# == Schema Information
#
# Table name: funding_sources
#
#  id         :integer          not null, primary key
#  name       :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FundingSource < ApplicationRecord
  # include SharedQueryableMethods

  has_many :funding_sources_sd_meta_data, inverse_of: :funding_source
  has_many :sd_meta_data, through: :funding_sources_sd_meta_data

  def self.by_query_and_page(query, page)
    result = if query.blank?
               all
             else
               where("#{name.pluralize.underscore}.name like ?", "%#{query}%")
             end

    result.page(page)
  end
end
