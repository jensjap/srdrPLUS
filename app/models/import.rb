# == Schema Information
#
# Table name: imports
#
#  id               :bigint           not null, primary key
#  import_type_id   :integer
#  projects_user_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Import < ApplicationRecord
  after_commit :start_import_job, on: :create

  belongs_to :import_type
  belongs_to :projects_user
  has_many :imported_files, dependent: :destroy

  delegate :user, to: :projects_user
  delegate :project, to: :projects_user

  accepts_nested_attributes_for :imported_files

  def start_import_job
    if self.import_type.name == "Distiller"
      DistillerImportJob.set(wait: 1.minute).perform_later(self.id)
      return
    end  # if self.import_type.name == "Distiller"

    for imported_file in self.imported_files
      case self.import_type.name
      when "Citation"
        case imported_file.file_type.name
        when ".ris"
          RisImportJob.set(wait: 1.minute).perform_later(imported_file.id)
        when ".csv"
          CsvImportJob.set(wait: 1.minute).perform_later(imported_file.id)
        when ".enl"
          EnlImportJob.set(wait: 1.minute).perform_later(imported_file.id)
        when "PubMed"
          PubmedImportJob.set(wait: 1.minute).perform_later(imported_file.id)
        when ".json"
          CitationFhirImportJob.set(wait: 1.minute).perform_later(imported_file.id)
        else
          ## NOT SUPPORTED, WHAT TO DO?
        end
      when "Project"
        case imported_file.file_type.name
        when ".json"
          JsonImportJob.set(wait: 1.minute).perform_later(imported_file.id)
        when ".xlsx"
          SimpleImportJob.set(wait: 1.minute).perform_later(imported_file.id)
        else
          ## NOT SUPPORTED, WHAT TO DO?
        end
      when "Assignments and Mappings"
        case imported_file.file_type.name
        when ".xlsx"
          ImportAssignmentsAndMappingsJob.set(wait: 1.minute).perform_later(imported_file.id)
        end  # case imported_file.file_type.name
      end  # case self.import_type.name
    end  # for imported_file in self.imported_files
  end  # def start_import_job
end  # class Import < ApplicationRecord
