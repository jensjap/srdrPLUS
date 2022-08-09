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
  before_destroy :really_destroy_children!
  def really_destroy_children!
    projects_studies.with_deleted.each do |child|
      child.really_destroy!
    end
  end

  has_many :projects_studies, dependent: :destroy, inverse_of: :study
  has_many :projects, through: :projects_studies, dependent: :destroy
end
