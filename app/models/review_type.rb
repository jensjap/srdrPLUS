# == Schema Information
#
# Table name: review_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ReviewType < ApplicationRecord
  include SharedQueryableMethods

  has_many :sd_meta_data, inverse_of: :review_type
end
