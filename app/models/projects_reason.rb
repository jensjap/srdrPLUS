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

  def self.reasons_object(project, screening_type)
    projects_reasons = ProjectsReason.where(project:, screening_type:).includes(:reason)
    projects_reasons.map do |projects_reason|
      {
        id: projects_reason.id,
        reason_id: projects_reason.reason_id,
        name: projects_reason.reason.name,
        pos: projects_reason.pos,
        selected: false
      }
    end
  end
end
