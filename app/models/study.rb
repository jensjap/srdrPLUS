# == Schema Information
#
# Table name: studies
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Study < ApplicationRecord
  acts_as_paranoid

  has_many :projects_studies, dependent: :destroy, inverse_of: :study
  has_many :projects, through: :projects_studies, dependent: :destroy
end
