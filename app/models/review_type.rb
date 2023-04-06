# == Schema Information
#
# Table name: review_types
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReviewType < ApplicationRecord
  include SharedQueryableMethods

  has_many :sd_meta_data, inverse_of: :review_type

  def self.by_query_and_page(query, page)
    result = if query.blank?
               all
             else
               where("#{name.pluralize.underscore}.name like ?", "%#{query}%")
             end

    result.page(page)
  end
end
