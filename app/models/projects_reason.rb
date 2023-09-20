# == Schema Information
#
# Table name: projects_reasons
#
#  id             :bigint           not null, primary key
#  project_id     :bigint           not null
#  reason_id      :bigint           not null
#  screening_type :string(255)      not null
#  pos            :integer          default(999999)
#  integer        :integer          default(999999)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class ProjectsReason < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :project
  belongs_to :reason

  ABSTRACT = 'abstract'.freeze
  FULLTEXT = 'fulltext'.freeze
end
