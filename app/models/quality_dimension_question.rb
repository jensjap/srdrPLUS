# == Schema Information
#
# Table name: quality_dimension_questions
#
#  id                           :integer          not null, primary key
#  quality_dimension_section_id :integer
#  name                         :string(255)
#  description                  :text(65535)
#  deleted_at                   :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

class QualityDimensionQuestion < ApplicationRecord
  acts_as_paranoid
  before_destroy :really_destroy_children!
  def really_destroy_children!
    dependencies.with_deleted.each do |child|
      child.really_destroy!
    end
    quality_dimension_questions_quality_dimension_options.with_deleted.each do |child|
      child.really_destroy!
    end
  end

  belongs_to :quality_dimension_section, inverse_of: :quality_dimension_questions

  has_many :dependencies, as: :dependable, dependent: :destroy
  has_many :quality_dimension_questions_quality_dimension_options, inverse_of: :quality_dimension_question,
                                                                   dependent: :destroy
  has_many :quality_dimension_options, through: :quality_dimension_questions_quality_dimension_options
end
