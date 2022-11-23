# == Schema Information
#
# Table name: records
#
#  id              :integer          not null, primary key
#  name            :text(65535)
#  recordable_type :string(255)
#  recordable_id   :integer
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Record < ApplicationRecord
  include SharedProcessTokenMethods

  acts_as_paranoid

  # after_commit :set_extraction_stale, on: [:create, :update, :destroy]
  after_commit :set_extraction_stale, on: [:update]

  belongs_to :recordable, polymorphic: true

  validate :check_constraints

  # So close, but doesn't work. This is nice because SimpleForm would automatically read the min and max constraints
  #  validates_length_of :name,
  #    minimum: self.recordable.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.find_by(question_row_column_option_id: 2).name.to_i,
  #    maximum: self.recordable.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.find_by(question_row_column_option_id: 3).name.to_i,
  #    allow_blank: true,
  #    on: :update,
  #    if: -> { self.recordable.question_row_column_field.question_row_column.question_row_column_type == QuestionRowColumnType.find_by(name: 'text') }

  #  def update(params)
  #    token        = params[:name]
  #    select2      = params[:select2].eql?('true') ? true : false
  #    select2Multi = params[:select2Multi].eql?('true') ? true : false
  #
  #    if select2
  #      #resource = self.recordable.question_row_column_field.question_row_column_fields_question_row_column_field_options.build(question_row_column_field_option_id: 1)
  #      resource = self.recordable.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.build(question_row_column_option_id: 1)
  #      save_resource_name_with_token(resource, token)
  #    elsif select2Multi
  #      token.each do |t|
  #        resource = self.recordable.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.build(question_row_column_option_id: 1)
  #        save_resource_name_with_token(resource, t)
  #      end
  #    end
  #
  #    params.delete(:select2)
  #    params.delete(:select2Multi)
  #    super
  #  end

  def name=(token)
    if !token.instance_of?(Array) && (recordable.instance_of? ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField)
      resource = recordable.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.build(question_row_column_option_id: 1)
      save_resource_name_with_token(resource, token)
    end
    #      else
    #        byebug
    #        token.each do |t|
    #          resource = self.recordable.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.build(question_row_column_option_id: 1)
    #          name = save_resource_name_with_token(resource, t).to_i
    #        end
    super
  end

  #  def name1=(tokens)
  #    tokens.each do |token|
  #      resource = self.recordable.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.build(question_row_column_option_id: 1)
  #      save_resource_name_with_token(resource, token)
  #    end
  #    super
  #  end

  def check_constraints
    case recordable
    when ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField
      case recordable.question_row_column_field.question_row_column.question_row_column_type.name
      when QuestionRowColumnType::TEXT
        min_length = recordable.question_row_column_field.question_row_column.field_validation_value_for(:min_length)
        max_length = recordable.question_row_column_field.question_row_column.field_validation_value_for(:max_length)
        min_length = min_length.blank? ? nil : min_length.to_i
        max_length = max_length.blank? ? nil : max_length.to_i

        if persisted? && name.present?
          if min_length && max_length && (name.length < min_length || name.length > max_length)
            errors.add(:length, "must be between #{min_length} and #{max_length} characters")
          elsif min_length && name.length < min_length
            errors.add(:length, "must be greater than or equal to #{min_length} characters")
          elsif max_length && name.length > max_length
            errors.add(:length, "must be less than or equal to #{max_length} characters")
          end
        end
      when QuestionRowColumnType::NUMERIC
        # First check that we aren't trying to validate any of the ~, <, >, ≤, ≥ special characters.
        if recordable.question_row_column_field.question_row_column.question_row_column_fields.second == recordable.question_row_column_field
          errors.add(:value, 'Must be numeric') unless (name =~ /\A[-+]?[0-9]*\.?[0-9]+\z/) || name.blank?
          min_value = recordable.question_row_column_field.question_row_column.field_validation_value_for(:min_value)
          max_value = recordable.question_row_column_field.question_row_column.field_validation_value_for(:max_value)
          min_value = min_value.blank? ? nil : min_value.to_i
          max_value = max_value.blank? ? nil : max_value.to_i

          if persisted? && name.present?
            if min_value && max_value && (name.to_i < min_value || name.to_i > max_value)
              errors.add(:value, "must be numeric and between #{min_value} and #{max_value}")
            elsif min_value && name.to_i < min_value
              errors.add(:value, "must be numeric and greater or equal to #{min_value}")
            elsif max_value && name.to_i > max_value
              errors.add(:value, "must be numeric and less than or equal to #{max_value}")
            end
          end
        end
      end
    end
  end

  def project
    case recordable_type
    when 'ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField'
      recordable.project
    when 'TpsArmsRssm'
      recordable.extractions_extraction_forms_projects_sections_type1.project
    when 'TpsComparisonsRssm'
      recordable.result_statistic_sections_measure.result_statistic_section.project
    when 'ComparisonsArmsRssm'
      recordable.extractions_extraction_forms_projects_sections_type1.project
    when 'WacsBacsRssm'
      recordable.result_statistic_section.project
    when 'ExtractionsExtractionFormsProjectsSectionsFollowupField'
      recordable.extractions_extraction_forms_projects_section.project
    end
  end

  private

  def set_extraction_stale
    #    time_now = DateTime.now.to_i
    #    UpdateExtractionChecksumJob.set(wait: 2.minute).perform_later(time_now.to_i, self.id)
    extraction = nil
    extraction = case recordable.class.name
                 when 'ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField',
      'ExtractionsExtractionFormsProjectsSectionsFollowupField'
                   recordable.extraction
                 else
                   recordable.result_statistic_section.extraction
                 end
    extraction.extraction_checksum.update(is_stale: true) unless extraction.nil? || extraction.deleted?
  end
end
