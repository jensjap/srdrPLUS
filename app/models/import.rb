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

  def already_queued?
    return false unless import_type.name == 'Project'

    Sidekiq::ScheduledSet.new.each do |scheduled_job|
      job_hash = JSON.parse(scheduled_job.value)['args'].try(:first) || {}
      scheduled_job_class = job_hash['job_class']
      scheduled_job_arguments = job_hash['arguments']

      imported_files.each do |imported_file|
        next unless imported_file.file_type.name == '.xlsx'

        import_job_class = SimpleImportJob.to_s
        import_job_arguments = [imported_file.id, project.id]
        return true if scheduled_job_class == import_job_class && scheduled_job_arguments[1] == import_job_arguments[1]
      end
    end

    workers = Sidekiq::Workers.new.to_a.map { |worker| worker[2]['payload']['args'].try(:first) || {} }
    workers.each do |worker|
      scheduled_job_class = worker['job_class']
      scheduled_job_arguments = worker['arguments']

      imported_files.each do |imported_file|
        next unless imported_file.file_type.name == '.xlsx'

        import_job_class = SimpleImportJob.to_s
        import_job_arguments = [imported_file.id, project.id]
        return true if scheduled_job_class == import_job_class && scheduled_job_arguments[1] == import_job_arguments[1]
      end
    end
    false
  end

  def start_import_job
    if import_type.name == 'Distiller'
      DistillerImportJob.set(wait: 1.minute).perform_later(id)
      return
    end # if self.import_type.name == "Distiller"

    for imported_file in imported_files
      case import_type.name
      when 'Citation'
        case imported_file.file_type.name
        when '.ris'
          RisImportJob.set(wait: 1.minute).perform_later(imported_file.id)
        when '.csv'
          CsvImportJob.set(wait: 1.minute).perform_later(imported_file.id)
        when '.enl'
          EnlImportJob.set(wait: 1.minute).perform_later(imported_file.id)
        when 'PubMed'
          PubmedImportJob.set(wait: 1.minute).perform_later(imported_file.id)
        when '.json'
          CitationFhirImportJob.set(wait: 1.minute).perform_later(imported_file.id)
        else
          ## NOT SUPPORTED, WHAT TO DO?
        end
      when 'Project'
        case imported_file.file_type.name
        when '.json'
          JsonImportJob.set(wait: 1.minute).perform_later(imported_file.id)
        when '.xlsx'
          SimpleImportJob.set(wait: 1.minute).perform_later(imported_file.id, project.id)
        else
          ## NOT SUPPORTED, WHAT TO DO?
        end
      when 'Assignments and Mappings'
        case imported_file.file_type.name
        when '.xlsx'
          ImportAssignmentsAndMappingsJob.set(wait: 1.minute).perform_later(imported_file.id)
        end # case imported_file.file_type.name
      end # case self.import_type.name
    end # for imported_file in self.imported_files
  end # def start_import_job
end  # class Import < ApplicationRecord
