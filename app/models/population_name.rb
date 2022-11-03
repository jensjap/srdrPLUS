# == Schema Information
#
# Table name: population_names
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)      not null
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PopulationName < ApplicationRecord
  acts_as_paranoid
  before_destroy :really_destroy_children!
  def really_destroy_children!
    extractions_extraction_forms_projects_sections_type1_rows.with_deleted.each do |child|
      child.really_destroy!
    end
  end

  has_many :extractions_extraction_forms_projects_sections_type1_rows, dependent: :destroy, inverse_of: :population_name

  validates :description, uniqueness: { scope: :name }

  def name_and_description
    text  = name
    text += " (#{description})" if description.present?
    text
  end

  def short_name_and_description
    text  = name
    text += " (#{description.truncate(16, separator: /\s/)})" if description.present?
    text
  end

  def select_label
    text  = "#{name}"
    text += " (#{description})" if description.present?
    text
  end
end
