# == Schema Information
#
# Table name: fulltext_screenings_users
#
#  id                    :bigint           not null, primary key
#  fulltext_screening_id :bigint           not null
#  user_id               :bigint           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
class FulltextScreeningsUser < ApplicationRecord
  belongs_to :fulltext_screening
  belongs_to :user

  delegate :handle, to: :user
end
