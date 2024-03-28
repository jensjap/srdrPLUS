# == Schema Information
#
# Table name: word_weights
#
#  id         :bigint           not null, primary key
#  weight     :integer          not null
#  word       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :integer
#
class WordWeight < ApplicationRecord
  belongs_to :project
  belongs_to :word_group
end
