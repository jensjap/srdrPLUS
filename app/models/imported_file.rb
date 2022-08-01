# == Schema Information
#
# Table name: imported_files
#
#  id              :integer          not null, primary key
#  file_type_id    :integer
#  section_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  key_question_id :integer
#  import_id       :integer
#

class ImportedFile < ApplicationRecord
  validates :content, :presence => true

  has_one_attached :content, service: :amazon_citation_import

  belongs_to :import
  belongs_to :file_type
  belongs_to :section, optional: true
  belongs_to :key_question, optional: true

  has_one :projects_user, through: :import

  delegate :project, to: :projects_user
  delegate :user, to: :projects_user

  accepts_nested_attributes_for :section
  accepts_nested_attributes_for :key_question

  def key_question=(args)
    args = KeyQuestion.find_or_create_by!(args)
    super(args)
  end

  def section=(args)
    args = Section.find_or_create_by!(args)
    super(args)
  end
end
