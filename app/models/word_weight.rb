# == Schema Information
#
# Table name: word_weights
#
#  id                                         :bigint           not null, primary key
#  abstract_screenings_projects_users_role_id :bigint
#  weight                                     :integer          not null
#  word                                       :string(255)      not null
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#
class WordWeight < ApplicationRecord
  belongs_to :abstract_screenings_projects_users_role
  delegate :abstract_screening, to: :abstract_screenings_projects_users_role
end
