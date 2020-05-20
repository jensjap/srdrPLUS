# == Schema Information
#
# Table name: imported_files
#
# t.integer "import_type_id"
# t.integer "projects_user_id"
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false
#

class Import < ApplicationRecord
  belongs_to :import_type
  belongs_to :projects_user

  has_many :imported_files, dependent: :destroy

  accepts_nested_attributes_for :imported_files

  after_create_commit :start_import_job

  def start_import_job
    for imported_file in self.imported_files
      case self.import_type.name
        when "Distiller References"
          case imported_file.file_type.name
            when ".ris"
              #RisImportJob.perform_later(self.user.id, self.project.id, self.id)
              DistillerImportJob.perform_later(imported_file.id)
            when ".csv"
              #CsvImportJob.perform_later(self.user.id, self.project.id, self.id)
              # WE SHOULD DO NOTHING HERE
            else
              ## NOT SUPPORTED, WHAT TO DO?
          end

        when "Distiller Section"
          case imported_file.file_type.name
            when ".csv"
              # WE SHOULD DO NOTHING HERE
            else
            ## NOT SUPPORTED, WHAT TO DO?
          end
        when "Citation"
          case imported_file.file_type.name
            when ".ris"
              RisImportJob.perform_later(imported_file.id)

            when ".csv"
              CsvImportJob.perform_later(imported_file.id)
            when ".enl"
              EnlImportJob.perform_later(imported_file.id)
            when "PubMed"
              PubmedImportJob.perform_later(imported_file.id)
            else
              ## NOT SUPPORTED, WHAT TO DO?
          end
        when "Project"
          case imported_file.file_type.name
            when ".json"
              JsonImportJob.perform_later(imported_file.id)
            else
              ## NOT SUPPORTED, WHAT TO DO?
          end
      end
    end
  end
end
