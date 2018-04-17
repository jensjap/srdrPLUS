class Record < ApplicationRecord
  include SharedProcessTokenMethods

  acts_as_paranoid
  has_paper_trail

  belongs_to :recordable, polymorphic: true

  validate :check_constraints

  def update(params)
    token    = params[:name]
    select2 = params[:select2].eql?('true') ? true : false

    if select2
      resource = self.recordable.question_row_column_field.question_row_column_fields_question_row_column_field_options.build(question_row_column_field_option_id: 1)
      save_resource_name_with_token(resource, token)
    end

    params.delete(:select2)
    super
  end

  def check_constraints
    min_length = self.recordable.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.find_by(question_row_column_option_id: 2).name.to_i
    max_length = self.recordable.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.find_by(question_row_column_option_id: 3).name.to_i
    errors.add(:length, "must be between #{ min_length.to_s } and #{ max_length.to_s }") if self.name.length < min_length || self.name.length > max_length
  end
end
