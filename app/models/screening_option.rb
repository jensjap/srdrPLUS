# == Schema Information
#
# Table name: screening_options
#
#  id                       :integer          not null, primary key
#  label_type_id            :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  project_id               :integer
#  screening_option_type_id :integer
#

class ScreeningOption < ApplicationRecord
  belongs_to :project # , touch: true
  belongs_to :label_type, optional: true
  belongs_to :screening_option_type
end
