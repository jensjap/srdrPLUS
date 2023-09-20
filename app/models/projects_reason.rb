class ProjectsReason < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :project
  belongs_to :reason

  ABSTRACT = 'abstract'.freeze
  FULLTEXT = 'fulltext'.freeze
end
