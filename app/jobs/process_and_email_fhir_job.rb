class ProcessAndEmailFhirJob < ApplicationJob
  queue_as :default

  def perform(project_id, user_email)
    begin
      project = Project.find(project_id)
      project_bundle = AllResourceSupplyingService.new.document_find_by_project_id(project.id)

      file_path = 'tmp/fhir_data_export_project_' + project_id.to_s + '_' + Time.now.strftime('%s') + '.json'
      File.write(file_path, project_bundle.to_json)

      export_type = ExportType.find_by(name: '.json')
      exported_item = ExportedItem.create! project: project, user_email: user_email, export_type: export_type
      exported_item.file.attach(io: File.open(file_path), filename: File.basename(file_path))

      if exported_item.file.attached?
        exported_item.external_url = exported_item.download_url
        exported_item.save!

        FhirMailer.with(user_email: user_email, download_url: exported_item.external_url).send_email.deliver_now
      else
        raise 'Cannot attach exported file'
      end
    rescue => e
      UserMailer.send_error_email(user_email).deliver_now
      Sentry.capture_exception(e) if Rails.env.production?
    end
  end
end
