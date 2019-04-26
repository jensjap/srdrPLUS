class ImportedFile < ApplicationRecord
  validates :content, :presence => true

  belongs_to :project
  belongs_to :user
  belongs_to :file_type
  belongs_to :import_type
  belongs_to :section, optional: true
  belongs_to :key_question, optional: true

  accepts_nested_attributes_for :section
  accepts_nested_attributes_for :key_question

  def initialize(params = {})
    file = params.delete(:content)
    super
    if file
      self.content = file.read
    end
  end

  def key_question=(args)
    args = KeyQuestion.find_or_create_by!(args)
    super(args)
  end

  def section=(args)
    args = Section.find_or_create_by!(args)
    super(args)
  end
end
