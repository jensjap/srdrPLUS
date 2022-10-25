# == Schema Information
#
# Table name: screening_qualifications
#
#  id                   :bigint           not null, primary key
#  citations_project_id :bigint
#  user_id              :bigint
#  qualification_type   :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class ScreeningQualification < ApplicationRecord
  AS_ACCEPTED = 'as-accepted'.freeze
  AS_REJECTED = 'as-rejected'.freeze
  FS_ACCEPTED = 'fs-accepted'.freeze
  FS_REJECTED = 'fs-rejected'.freeze
  E_REJECTED = 'e-rejected'.freeze
  E_UNREJECTED = 'e-unrejected'.freeze
  ALL_QUALIFICATIONS = [
    AS_ACCEPTED,
    AS_REJECTED,
    FS_ACCEPTED,
    FS_REJECTED,
    E_REJECTED,
    E_UNREJECTED
  ].freeze

  belongs_to :citations_project
  belongs_to :user, optional: true

  def self.opposite_qualification(screening_qualification_type)
    case screening_qualification_type
    when AS_ACCEPTED
      AS_REJECTED
    when AS_REJECTED
      AS_ACCEPTED
    when FS_ACCEPTED
      FS_REJECTED
    when FS_REJECTED
      FS_ACCEPTED
    when E_REJECTED
      E_UNREJECTED
    when E_UNREJECTED
      E_REJECTED
    end
  end
end
