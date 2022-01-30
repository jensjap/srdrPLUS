# == Schema Information
#
# Table name: import_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ImportType < ApplicationRecord
  DISTILLER_REFERENCES = 'Distiller References'.freeze
  DISTILLER_SECTION    = 'Distiller Section'.freeze
  CITATION             = 'Citation'.freeze
  PROJECT              = 'Project'.freeze
  DISTILLER            = 'Distiller'.freeze
  ASSIGNMENTS          = 'Assignments'.freeze
end
