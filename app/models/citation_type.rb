# == Schema Information
#
# Table name: citation_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CitationType < ApplicationRecord
  PRIMARY   = 'Primary'.freeze
  SECONDARY = 'Secondary'.freeze
  ABSTRACKR = 'Abstrackr'.freeze

  has_many :citations
end
