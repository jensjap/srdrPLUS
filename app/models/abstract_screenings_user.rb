# == Schema Information
#
# Table name: abstract_screenings_users
#
#  id                    :bigint           not null, primary key
#  abstract_screening_id :bigint           not null
#  user_id               :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class AbstractScreeningsUser < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :user

  delegate :handle, to: :user
end
