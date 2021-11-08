# == Schema Information
#
# Table name: extractions_extraction_forms_projects_sections
#
#  id                                               :integer          not null, primary key
#  extraction_id                                    :integer
#  extraction_forms_projects_section_id             :integer
#  extractions_extraction_forms_projects_section_id :integer
#  deleted_at                                       :datetime
#  active                                           :boolean
#  created_at                                       :datetime         not null
#  updated_at                                       :datetime         not null
#

class ExtractionsExtractionFormsProjectsSection < ApplicationRecord
  include SharedParanoiaMethods
  include SharedProcessTokenMethods

  acts_as_paranoid column: :active, sentinel_value: true

  #!!! Doesn't work
#  scope :result_type_sections, -> () {
#    joins(extraction_forms_projects_section: :section )
#      .where(extraction_forms_projects_sections: { sections: { name: 'Results' } }) }

  after_create :create_default_draft_status

  belongs_to :extraction,                        inverse_of: :extractions_extraction_forms_projects_sections
  belongs_to :extraction_forms_projects_section, inverse_of: :extractions_extraction_forms_projects_sections
  belongs_to :link_to_type1, class_name: 'ExtractionsExtractionFormsProjectsSection',
    foreign_key: 'extractions_extraction_forms_projects_section_id',
    optional: true

  has_one :statusing, as: :statusable, dependent: :destroy
  has_one :status, through: :statusing

  has_many :link_to_type2s, class_name: 'ExtractionsExtractionFormsProjectsSection',
    foreign_key: 'extractions_extraction_forms_projects_section_id'

  has_many :extractions_extraction_forms_projects_sections_type1s,
    -> { ordered },
    dependent: :destroy, inverse_of: :extractions_extraction_forms_projects_section
  has_many :type1s,
    -> { joins(extractions_extraction_forms_projects_sections_type1s: :ordering) },
    through: :extractions_extraction_forms_projects_sections_type1s, dependent: :destroy

  has_many :extractions_extraction_forms_projects_sections_question_row_column_fields, dependent: :destroy, inverse_of: :extractions_extraction_forms_projects_section
  has_many :question_row_column_fields, through: :extractions_extraction_forms_projects_sections_question_row_column_fields, dependent: :destroy

  has_many :extractions_extraction_forms_projects_sections_followup_fields, dependent: :destroy, inverse_of: :extractions_extraction_forms_projects_section
  has_many :followup_fields, through: :extractions_extraction_forms_projects_sections_followup_fields, dependent: :destroy

  accepts_nested_attributes_for :extractions_extraction_forms_projects_sections_type1s, reject_if: :all_blank
  accepts_nested_attributes_for :statusing, reject_if: :all_blank
  accepts_nested_attributes_for :status, reject_if: :all_blank
  #accepts_nested_attributes_for :type1s, reject_if: :all_blank

  delegate :citation,          to: :extraction
  delegate :citations_project, to: :extraction
  delegate :project,           to: :extraction
  delegate :section,           to: :extraction_forms_projects_section

  def extractions_extraction_forms_projects_sections_type1s_without_total_arm
    extractions_extraction_forms_projects_sections_type1s
      .to_a
      .delete_if { |efpst| efpst.type1.name == "Total" && efpst.type1.description == "All #{ link_to_type1.present? ? link_to_type1.section.name : section.name } combined" }
  end

  def type1s_suggested_by_project_leads
    extraction_forms_projects_section
      .extraction_forms_projects_sections_type1s
      .includes(:timepoint_names, :type1, type1: { suggestion: { user: :profile } })
      .where.not(type1: self.type1s)
      .where.not(type1s: { name: 'Total', description: "All #{ extraction_forms_projects_section.link_to_type1.present? ? extraction_forms_projects_section.link_to_type1.section.name : extraction_forms_projects_section.section.name } combined" })
      .distinct
  end

  def eefps_qrfc_values(eefpst1_id, qrc)
    recordables = extractions_extraction_forms_projects_sections_question_row_column_fields
      .where(extractions_extraction_forms_projects_sections_type1_id: eefpst1_id,
             question_row_column_field: qrc.question_row_column_fields)

    case qrc.question_row_column_type_id
    when 1, 2  # Textbox, Numeric.
      return Record.where(recordable: recordables).order(updated_at: :desc).pluck(:name).first.try(:strip)

    when 5  # Checkbox.
      text_arr = []
      Record.where(recordable: recordables).pluck(:name).each do |opt_ids|
        if (opt_ids.nil? || opt_ids.length < 4) then next end

        # There is some inconsistencies in how rails saves checkboxes.
        # In some cases opt_ids is a string with a single number, in other cases
        # we get something of the form "[\"\", \"118479\"]"
        # We clean the string when needed and convert to an Array.
        if opt_ids =~ /\"/
          cleaned_opt_ids = opt_ids[2..-3].split('", "')-[""]
        else
          cleaned_opt_ids = [] << opt_ids
        end
        cleaned_opt_ids.each do |opt_id|
          # opt_id can be nil here for questions that have not been answered.
          # Protect by casting to zero and check.

          qrcqrco = qrc.question_row_columns_question_row_column_options.find_by(id: opt_id.to_i)
          if qrcqrco.present? and not opt_id.to_i.zero?
            begin
              tmp_value = ''
              tmp_ff_value = ''
              if qrcqrco.name.present?
                tmp_value = qrcqrco.name
              else
                if qrcqrco.nil?
                  tmp_value = ''
                else
                  tmp_value = 'X'
                end
              end

              # Check for followup_field and append if present.
              if qrcqrco.followup_field.present?
                extraction_id = self.extraction.id
                eefpsff = qrcqrco.followup_field.extractions_extraction_forms_projects_sections_followup_fields.filter { |r| r.extraction.id == extraction_id }
                tmp_ff_value = "[Follow-up: #{eefpsff.map(&:records).flatten.map(&:name).join(', ')}]"
              end

              text_arr << tmp_value + tmp_ff_value

            rescue Exception => e
               #!!! This can happen when records are created and then the answer options are deleted or question type changes altogether.
               #    Need to decide what to do here.
              next
            end
          end  # if qrcqrco.present? and not opt_id.to_i.zero?
        end  # (opt_ids[2..-3].split('", "')-[""]).each do |opt_id|
      end  # Record.where(recordable: recordables).pluck(:name).each do |opt_ids|
      return text_arr.join("\x0D\x0A")

    when 6, 7, 8  # Dropdown, Radio, Select2_single.
      tmp_value = ''
      tmp_ff_value = ''
      opt_id = Record.where(recordable: recordables).order(updated_at: :desc).pluck(:name).first
      # opt_id can be nil here for questions that have not been answered.
      # Protect by casting to zero and check.
      begin
        tmp_value = qrc.question_row_columns_question_row_column_options.find(opt_id.to_i).name unless opt_id.to_i.zero?
      rescue Exception => e
        #!!! This can happen when records are created and then the answer options are deleted or question type changes altogether.
        #    Need to decide what to do here.
      end

      # Check for followup_field and append if present.
      qrcqrco = qrc.question_row_columns_question_row_column_options.find_by(id: opt_id.to_i)
      if qrcqrco.present?
        if qrcqrco.followup_field.present?
          extraction_id = self.extraction.id
          eefpsff = qrcqrco.followup_field.extractions_extraction_forms_projects_sections_followup_fields.filter { |r| r.extraction.id == extraction_id }
          tmp_ff_value = "[Follow-up: #{eefpsff.map(&:records).flatten.map(&:name).join(', ')}]"
        end
      end
      return (tmp_value + tmp_ff_value).try(:strip)

    when 9  # Select2_multi.
      text_arr = []
      ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldsQuestionRowColumnsQuestionRowColumnOption
        .includes(:question_row_columns_question_row_column_option)
        .where(extractions_extraction_forms_projects_sections_question_row_column_field: recordables).each do |eefpsqrcfqrcqrco|

        begin
          text_arr << eefpsqrcfqrcqrco.question_row_columns_question_row_column_option.name
        rescue Exception => e
          #!!! This can happen when records are created and then the answer options are deleted or question type changes altogether.
          #    Need to decide what to do here.
          next
        end
      end
      return text_arr.join("\x0D\x0A")

    else
      return Record.where(recordable: recordables).pluck(:name).join("\x0D\x0A")

    end
  end

  def eefpst1s_only_total
    type1 = Type1.find_or_create_by(
      name: "Total",
      description: "All #{extraction_forms_projects_section.link_to_type1.present? ?
        extraction_forms_projects_section.link_to_type1.section.name :
        extraction_forms_projects_section.section.name} combined"
    )
    type1s << type1 unless type1s.include? type1
    sort_by_their_orderings(
      [
        extractions_extraction_forms_projects_sections_type1s.
          includes(:ordering).
          joins(:type1).
          find_by(
            type1s: {
              name: 'Total',
              description: "All #{extraction_forms_projects_section.link_to_type1.present? ?
                extraction_forms_projects_section.link_to_type1.section.name :
                extraction_forms_projects_section.section.name} combined"
            }
          )
      ]
    )
  end

  def eefpst1s_without_total
    sort_by_their_orderings(
      extractions_extraction_forms_projects_sections_type1s
        .includes(:type1_type, :type1, :ordering)
        .to_a
        .delete_if { |eefpst1| eefpst1.type1 == Type1.find_by(name: 'Total', description: "All #{ extraction_forms_projects_section.link_to_type1.present? ? extraction_forms_projects_section.link_to_type1.section.name : extraction_forms_projects_section.section.name } combined") }
    )
  end

  def eefpst1s_with_total
    type1 = Type1.find_or_create_by(
      name: "Total",
      description: "All #{extraction_forms_projects_section.link_to_type1.present? ?
        extraction_forms_projects_section.link_to_type1.section.name :
        extraction_forms_projects_section.section.name} combined"
    )
    type1s << type1 unless type1s.include? type1
    eefpst1s = extractions_extraction_forms_projects_sections_type1s
      .includes(:type1_type, :type1)
      .to_a
      .delete_if { |eefpst1| eefpst1.type1 == Type1.find_by(name: 'Total', description: "All #{ extraction_forms_projects_section.link_to_type1.present? ? extraction_forms_projects_section.link_to_type1.section.name : extraction_forms_projects_section.section.name } combined") }
      .push(extractions_extraction_forms_projects_sections_type1s.includes(:ordering).joins(:type1).find_by(type1s: { name: 'Total', description: "All #{ extraction_forms_projects_section.link_to_type1.present? ? extraction_forms_projects_section.link_to_type1.section.name : extraction_forms_projects_section.section.name } combined" }))
    raise if eefpst1s.any?(&:nil?)

    return sort_by_their_orderings(eefpst1s)
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

  def extractions_extraction_forms_projects_sections_type1s_attributes=(attributes)
    attributes.each do |key, attribute_collection|
      unless attribute_collection.has_key? 'id'
        Type1.transaction do
          type1 = Type1.find_or_create_by!(attribute_collection['type1_attributes'])
          attributes[key]['type1_attributes']['id'] = type1.id.to_s
        end
      end
    end
    super
  end

  # Create default draft status
  def create_default_draft_status
    if statusing.nil?
      create_statusing( status: Status.find_by(name: 'Draft'))
    end
  end

  # If you try to use accepts_nested_attributes_for :status, you get:
  #   "Cannot build association 'status'. Are you trying to build a polymorphic one-to-one association."
  # So we are creating a build method manually
  def build_status(params)
    new_status = Status.find_by(params)
    if new_status.present?
      if statusing.present?
        statusing.update(statusable: self, status: new_status)
      else
        create_statusing(status: new)
      end
    end
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
  private
    def sort_by_their_orderings(eefpst1s)
      max_position = eefpst1s.map { |eefpst1| eefpst1.ordering.position }.max

      eefpst1s.sort_by do |eefpst1|
        if eefpst1.type1 == Type1.find_by(
          name: 'Total',
          description: "All #{extraction_forms_projects_section.link_to_type1.present? ?
            extraction_forms_projects_section.link_to_type1.section.name :
            extraction_forms_projects_section.section.name} combined"
        )
          max_position + 1
        else
          eefpst1.ordering.position
        end
      end
    end
end
