# == Schema Information
#
# Table name: exported_items
#
#  id               :bigint           not null, primary key
#  projects_user_id :integer
#  export_type_id   :bigint
#  external_url     :text(16777215)
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ExportedItem < ApplicationRecord
  belongs_to :projects_user
  belongs_to :export_type

  has_one_attached :file
end
