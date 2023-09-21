# == Schema Information
#
# Table name: projects_tags
#
#  id             :bigint           not null, primary key
#  project_id     :bigint           not null
#  tag_id         :bigint           not null
#  screening_type :string(255)      not null
#  pos            :integer          default(999999)
#  integer        :integer          default(999999)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class ProjectsTag < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :project
  belongs_to :tag

  ABSTRACT = 'abstract'.freeze
  FULLTEXT = 'fulltext'.freeze

  def self.tags_object(project, screening_type)
    ProjectsTag
      .where(project:, screening_type:)
      .includes(:tag)
      .map do |projects_tag|
      {
        id: projects_tag.id,
        tag_id: projects_tag.tag_id,
        name: projects_tag.tag.name,
        pos: projects_tag.pos,
        selected: false,
        selected_id: nil
      }
    end
  end
end
