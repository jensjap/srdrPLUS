class ExtractionsExtractionFormsProjectsSection < ApplicationRecord
  include SharedParanoiaMethods
  include SharedProcessTokenMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  #!!! Doesn't work
#  scope :result_type_sections, -> () {
#    joins(extraction_forms_projects_section: :section )
#      .where(extraction_forms_projects_sections: { sections: { name: 'Results' } }) }

  belongs_to :extraction,                        inverse_of: :extractions_extraction_forms_projects_sections
  belongs_to :extraction_forms_projects_section, inverse_of: :extractions_extraction_forms_projects_sections
  belongs_to :link_to_type1, class_name: 'ExtractionsExtractionFormsProjectsSection',
    foreign_key: 'extractions_extraction_forms_projects_section_id',
    optional: true

  has_many :extractions_extraction_forms_projects_sections_type1s, dependent: :destroy, inverse_of: :extractions_extraction_forms_projects_section
  has_many :type1s, through: :extractions_extraction_forms_projects_sections_type1s, dependent: :destroy

  has_many :extractions_extraction_forms_projects_sections_question_row_column_fields, dependent: :destroy, inverse_of: :extractions_extraction_forms_projects_sections_type1
  has_many :question_row_column_fields, through: :extractions_extraction_forms_projects_sections_question_row_column_fields, dependent: :destroy

  accepts_nested_attributes_for :type1s, reject_if: :all_blank

  delegate :citation,          to: :extraction
  delegate :citations_project, to: :extraction
  delegate :section,           to: :extraction_forms_projects_section
  delegate :project,           to: :extraction_forms_projects_section

  def eefps_qrfc_values(eefpst1_id, qrc)
    recordables = extractions_extraction_forms_projects_sections_question_row_column_fields
      .where(extractions_extraction_forms_projects_sections_type1_id: eefpst1_id,
             question_row_column_field: qrc.question_row_column_fields)
    if [5, 6, 7, 8, 9].include? qrc.question_row_column_type_id
      text = ''
      Record.where(recordable: recordables).pluck(:name).each do |opt_id|
        # opt_id can be nil here for questions that have not been answered.
        # Protect by casting to zero and check.
        text += qrc.question_row_columns_question_row_column_options.find(opt_id.to_i).name + "\r" unless opt_id.to_i.zero?
      end

      return text
    else
      return Record.where(recordable: recordables).pluck(:name).join('\r')
    end
  end

  # Do not create duplicate Type1 entries.
  #
  # In nested forms, the type1s_attributes hash will have IDs for entries that
  # are being modified (i.e. are tied to an existing record). We want to skip
  # over them. The ones that are lacking an ID entry are entries that are not
  # yet tied to an existing record. For these we check if they already exist
  # (by name and description) and then add to
  # extraction_forms_projects_section.type1s collection. Then call super to
  # update all the attributes of all submitted records.
  #
  # Note: This actually breaks validation. Presumably because validations happen
  #       later, after calling super. This is not a problem since there's
  #       nothing inherently wrong with creating an association between eefps and
  #       type1, where type1 has neither name or nor description.
  def type1s_attributes=(attributes)
    attributes.each do |key, attribute_collection|
      unless attribute_collection.has_key? 'id'
        Type1.transaction do
          type1 = Type1.find_or_create_by!(attribute_collection)
          type1s << type1 unless type1s.include? type1
          attributes[key]['id'] = type1.id.to_s
        end
      end
    end
    super
  end

#  def to_builder
#    Jbuilder.new do |json|
#      json.name extraction_forms_projects_section.section.name
#      if extraction_forms_projects_section.extraction_forms_projects_section_type_id == 1
#        json.type1s extractions_extraction_forms_projects_sections_type1s.map { |eefpst1| eefpst1.to_builder.attributes! }
#      elsif extraction_forms_projects_section.extraction_forms_projects_section_type_id == 2
#        json.array! extraction_forms_projects_section.questions
#      end
#    end
#  end
end
