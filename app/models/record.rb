class Record < ApplicationRecord
  include SharedProcessTokenMethods

  acts_as_paranoid
  has_paper_trail

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
      resource = self.recordable.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.build(question_row_column_option_id: 1)
      save_resource_name_with_token(resource, token)
      super
    else
      byebug
      token.each do |t|
        resource = self.recordable.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.build(question_row_column_option_id: 1)
        name = save_resource_name_with_token(resource, t).to_i
        super
      end
    end
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
      if self.recordable.question_row_column_field.question_row_column.question_row_column_type == QuestionRowColumnType.find_by(name: 'text')  # Text
        min_length = self.recordable.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.find_by(question_row_column_option_id: 2).name.to_i
        max_length = self.recordable.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.find_by(question_row_column_option_id: 3).name.to_i
        if self.persisted? && self.name.length > 0 && (self.name.length < min_length || self.name.length > max_length)
          errors.add(:length, "must be between #{ min_length.to_s } and #{ max_length.to_s }")
        end
      end
    else
    end
  end
end
