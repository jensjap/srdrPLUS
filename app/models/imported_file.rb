class ImportedFile < ApplicationRecord
  validates :content, :presence => true

  has_one_attached :content

  belongs_to :project
  belongs_to :user
  belongs_to :file_type
  belongs_to :import_type
  belongs_to :section, optional: true
  belongs_to :key_question, optional: true

  accepts_nested_attributes_for :section
  accepts_nested_attributes_for :key_question

  after_create_commit :start_import_job

  # def initialize(params = {})
  #   file = params.delete(:content)
  #   super
  #   if file
  #     self.content = file.read
  #   end
  # end
  #

  def start_import_job
    case self.import_type.name
      when "Distiller References"
        case self.file_type.name
          when ".ris"
            #RisImportJob.perform_later(self.user.id, self.project.id, self.id)
            DistillerImportJob.perform_later(self.user.id, self.project.id, self.id)
          when ".csv"
            #CsvImportJob.perform_later(self.user.id, self.project.id, self.id)
            # WE SHOULD DO NOTHING HERE
          else
            ## NOT SUPPORTED, WHAT TO DO?
        end

      when "Distiller Section"
        case self.file_type.name
          when ".csv"
            # WE SHOULD DO NOTHING HERE
          else
          ## NOT SUPPORTED, WHAT TO DO?
        end
      when "Citation"
        case self.file_type.name
          when ".ris"
            RisImportJob.perform_later(self.user.id, self.project.id, self.id)

          when ".csv"
            CsvImportJob.perform_later(self.user.id, self.project.id, self.id)
          when ".enl"
            EnlImportJob.perform_later(self.user.id, self.project.id, self.id)
          when "Pubmed"
            PubmedImportJob.perform_later(self.user.id, self.project.id, self.id)
          else
            ## NOT SUPPORTED, WHAT TO DO?
        end
      when "Project"
        case self.file_type.name
          when ".json"
            JsonImportJob.perform_later(self.user.id, self.project.id, self.id)
          else
            ## NOT SUPPORTED, WHAT TO DO?
        end
    end
  end

  def key_question=(args)
    args = KeyQuestion.find_or_create_by!(args)
    super(args)
  end

  def section=(args)
    args = Section.find_or_create_by!(args)
    super(args)
  end
end
