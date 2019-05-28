# == Schema Information
#
# Table name: exported_files
#
#  id           :integer          not null, primary key
#  project_id   :integer
#  user_id      :integer
#  file_type_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ExportedFile < ApplicationRecord
  validates :content, :presence => true

  has_one_attached :content

  belongs_to :project
  belongs_to :user
  belongs_to :file_type
end
