# == Schema Information
#
# Table name: word_weights
#
#  id                    :bigint           not null, primary key
#  weight                :integer          not null
#  word                  :string(255)      not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  project_id            :integer
#  user_id               :integer          default(1), not null
#  abstract_screening_id :bigint           default(1), not null
#  word_group_id         :bigint
#
class WordWeight < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :abstract_screening, optional: true
  belongs_to :word_group
end
