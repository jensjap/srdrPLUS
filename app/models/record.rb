class Record < ApplicationRecord
  include SharedProcessTokenMethods

  acts_as_paranoid
  has_paper_trail

  after_commit :set_extraction_stale, [:create, :update, :destroy]

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
    unless token.instance_of? Array
      if self.recordable.instance_of? ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField
        resource = self.recordable.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.build(question_row_column_option_id: 1)
        save_resource_name_with_token(resource, token)
      end
#      else
#        byebug
#        token.each do |t|
#          resource = self.recordable.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.build(question_row_column_option_id: 1)
#          name = save_resource_name_with_token(resource, t).to_i
#        end
    end
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
    case self.recordable
    when ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField
      case self.recordable.question_row_column_field.question_row_column.question_row_column_type.name
      when 'text'
        min_length = self.recordable.question_row_column_field.question_row_column.field_validation_value_for(:min_length).to_i
        max_length = self.recordable.question_row_column_field.question_row_column.field_validation_value_for(:max_length).to_i
        if self.persisted? && self.name.length > 0 && (self.name.length < min_length || self.name.length > max_length)
          errors.add(:length, "must be between #{ min_length.to_s } and #{ max_length.to_s }")
        end
      when 'numeric'
        # First check that we aren't trying to validate any of the ~, <, >, ≤, ≥ special characters.
        if self.recordable.question_row_column_field.question_row_column.question_row_column_fields.second == self.recordable.question_row_column_field
          unless (self.name =~ /\A[-+]?[0-9]*\.?[0-9]+\z/) || self.name != ''
            errors.add(:value, 'Must be numeric')
          end

          min_value = self.recordable.question_row_column_field.question_row_column.field_validation_value_for(:min_value).to_i
          max_value = self.recordable.question_row_column_field.question_row_column.field_validation_value_for(:max_value).to_i
          if self.persisted? && (self.name.to_i < min_value || self.name.to_i > max_value)
            errors.add(:value, "must be numeric and between #{ min_value.to_s } and #{ max_value.to_s }")
          end
        end
      end
    end
  end

  def set_extraction_stale
#    time_now = DateTime.now.to_i
#    UpdateExtractionChecksumJob.set(wait: 2.minute).perform_later(time_now.to_i, self.id)
    extraction = nil
    case recordable.class.name
    when 'ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField'
      extraction = recordable.extraction
    else
      extraction = recordable.result_statistic_section.extraction
    end
    extraction.extraction_checksum.update( is_stale: true ) 
  end
end
