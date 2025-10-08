# == Schema Information
#
# Table name: word_weights
#
#  id                    :bigint           not null, primary key
#  user_id               :bigint
#  abstract_screening_id :bigint
#  weight                :integer          not null
#  word                  :string(255)      not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  word_group_id         :bigint
#
class WordWeight < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :abstract_screening, optional: true
  belongs_to :word_group
end
