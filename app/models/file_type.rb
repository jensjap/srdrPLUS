# == Schema Information
#
# Table name: file_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class FileType < ApplicationRecord
  CSV       = '.csv'
  RIS       = '.ris'
  XLSX      = '.xlsx'
  ENL       = '.enl'
  PUBMED    = 'PubMed'
  JSON      = '.json'
  DISTILLER = 'Distiller Section'
end
