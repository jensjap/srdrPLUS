# == Schema Information
#
# Table name: timepoint_names
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  unit              :string(255)      default(""), not null
#  deleted_at        :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  isValidUCUM       :boolean          default(FALSE)
#  isValidUCUMTested :boolean          default(FALSE)
#

class TimepointName < ApplicationRecord
  SERVICE_ADDRESS = "https://ucum.nlm.nih.gov/ucum-service/v1/isValidUCUM/".freeze

  include SharedQueryableMethods

  acts_as_paranoid

  after_create :test_isValidUCUM

  has_many :extractions_extraction_forms_projects_sections_type1_row_columns, dependent: :destroy, inverse_of: :timepoint_name

  has_many :extraction_forms_projects_sections_type1s_timepoint_names, dependent: :destroy, inverse_of: :timepoint_name
  has_many :extraction_forms_projects_sections_type1s, through: :extraction_forms_projects_sections_type1s_timepoint_names, dependent: :destroy

  validates :unit, uniqueness: { scope: :name }

  # Written in one line.
  def pretty_print_export_header
    text  = name
    text += " (#{ unit })" if unit.present?
    return text
  end

  private

    def select_label
      text  = "#{ name }"
      text += " (#{ unit })" if unit.present?
      return text
    end

    def test_isValidUCUM
      url = SERVICE_ADDRESS + CGI.escape(self.unit)
      begin
        resp = HTTParty.get(url).body
        self.isValidUCUM = ActiveModel::Type::Boolean.new.cast(resp)
        self.isValidUCUMTested = true
        self.save

      rescue Exception => e
        self.isValidUCUMTested = false
        self.save

      end
    end
end
