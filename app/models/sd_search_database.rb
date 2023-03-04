# == Schema Information
#
# Table name: sd_search_databases
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SdSearchDatabase < ApplicationRecord
  # include SharedQueryableMethods
  has_many :sd_search_strategies, inverse_of: :sd_search_database, dependent: :nullify
  has_many :sd_meta_data, through: :sd_search_strategies

  def self.by_query_and_page(query, page)
    result = if query.blank?
               all
             else
               where("#{name.pluralize.underscore}.name like ?", "%#{query}%")
             end

    result.page(page)
  end
end
