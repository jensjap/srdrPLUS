class ExportedItem < ApplicationRecord
  belongs_to :projects_user
  belongs_to :export_type

  has_one_attached :file
end
