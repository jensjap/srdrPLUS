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
    Rails.application.routes.url_helpers.rails_blob_url(self.file, host: Rails.application.routes.default_url_options[:host])
  end
end
