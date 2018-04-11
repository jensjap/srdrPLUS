class Record < ApplicationRecord
  include SharedProcessTokenMethods

  acts_as_paranoid
  has_paper_trail

  belongs_to :recordable, polymorphic: true

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
end
