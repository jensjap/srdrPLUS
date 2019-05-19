class ExportedFile < ApplicationRecord
  validates :content, :presence => true

  has_one_attached :content

  belongs_to :project
  belongs_to :user
  belongs_to :file_type
end
