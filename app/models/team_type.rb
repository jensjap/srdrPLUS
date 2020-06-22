# == Schema Information
#
# Table name: team_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TeamType < ApplicationRecord
  has_many :teams
end
