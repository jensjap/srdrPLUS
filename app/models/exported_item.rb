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
  belongs_to :user, optional: true
  belongs_to :project

  has_one_attached :file
end
