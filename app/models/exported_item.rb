# == Schema Information
#
# Table name: exported_items
#
#  id               :bigint           not null, primary key
#  projects_user_id :integer
#  export_type_id   :bigint
#  external_url     :text(65535)
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_email       :string(255)
#  project_id       :bigint
#

class ExportedItem < ApplicationRecord
  belongs_to :export_type
  belongs_to :user, optional: true
  belongs_to :project
  belongs_to :projects_user

  has_one_attached :file
end
