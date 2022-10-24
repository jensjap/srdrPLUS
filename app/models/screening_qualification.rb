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

  belongs_to :citations_project
  belongs_to :user, optional: true
end
