# == Schema Information
#
# Table name: exported_items
#
#  id             :bigint           not null, primary key
#  export_type_id :bigint
#  external_url   :text(65535)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  user_email     :string(255)
#  project_id     :bigint
#

class ExportedItem < ApplicationRecord
  belongs_to :export_type
  belongs_to :project

  has_one_attached :file

  def download_url
    case file.service.class.name
    when 'ActiveStorage::Service::DiskService'
      Rails.application.routes.url_helpers.rails_blob_url(
        file,
        host: Rails.application.routes.default_url_options[:host]
      )

    when 'ActiveStorage::Service::S3Service'
      file.service.bucket.object(file.key).presigned_url(:get, expires_in: 1.week.in_seconds)

    else
      'Unknown ActiveStorage::Service'

    end
  end
end
