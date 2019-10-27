# == Schema Information
#
# Table name: journals
#
#  id               :integer          not null, primary key
#  citation_id      :integer
#  volume           :integer
#  issue            :integer
#  name             :string(1000)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  publication_date :string(255)
#

class Journal < ApplicationRecord
  belongs_to :citation, optional: true
end
