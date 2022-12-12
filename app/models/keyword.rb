# == Schema Information
#
# Table name: keywords
#
#  id         :integer          not null, primary key
#  name       :string(5000)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Keyword < ApplicationRecord
  include SharedQueryableMethods
  has_and_belongs_to_many :citations
end
