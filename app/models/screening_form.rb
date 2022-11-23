# == Schema Information
#
# Table name: screening_forms
#
#  id         :bigint           not null, primary key
#  project_id :bigint
#  form_type  :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ScreeningForm < ApplicationRecord
  belongs_to :project
  has_many :sf_questions, dependent: :destroy, inverse_of: :screening_form
end
