# == Schema Information
#
# Table name: question_row_column_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class QuestionRowColumnType < ApplicationRecord
  TEXT = 'text'.freeze
  NUMERIC = 'numeric'.freeze
  NUMERIC_RANGE = 'numeric_range'.freeze
  SCIENTIFIC = 'scientific'.freeze
  CHECKBOX = 'checkbox'.freeze
  DROPDOWN = 'dropdown'.freeze
  RADIO = 'radio'.freeze
  SELECT2_SINGLE = 'select2_single'.freeze
  SELECT2_MULTI = 'select2_multi'.freeze

  DEFAULT_QRC_TYPES = ['Text Field (alphanumeric)',
    'Numeric Field (numeric)',
    'Checkbox (select multiple)',
    'Dropdown (select one)',
    'Radio (select one)',
    'Select one (with write-in option)',
    'Select multiple (with write-in option)'
  ].zip(QuestionRowColumnType.
    where(id: [1, 2, 5, 6, 7, 8, 9]).
    pluck(:id)).
    freeze


  acts_as_paranoid

  has_many :question_row_columns, dependent: :destroy, inverse_of: :question_row_column_type
end
