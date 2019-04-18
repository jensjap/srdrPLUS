class ImportedFile < ApplicationRecord
  belongs_to :project
  belongs_to :user
  belongs_to :file_type
  belongs_to :import_type
  belongs_to :section, optional: true

  accepts_nested_attributes_for :section

  def initialize(params = {})
    file = params.delete(:content)
    super
    if file
      self.content = file.read
    end
  end

  def start_distiller_import

  end
end
