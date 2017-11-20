class Citation < ApplicationRecord
  include SharedQueryableMethods

  belongs_to :citation_type

  has_one :journal, dependent: :destroy

  has_many :citations_projects, dependent: :destroy
  has_many :projects, through: :citations_projects
  has_many :authors, dependent: :destroy
  has_many :keywords, dependent: :destroy
  has_many :labels, through: :citations_projects

  accepts_nested_attributes_for :authors, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :keywords, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :journal, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :labels, reject_if: :all_blank, allow_destroy: true
end