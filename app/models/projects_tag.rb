class ProjectsTag < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :project
  belongs_to :tag

  ABSTRACT = 'abstract'.freeze
  FULLTEXT = 'fulltext'.freeze
end
