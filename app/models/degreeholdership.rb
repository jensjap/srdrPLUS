class Degreeholdership < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :degree
  belongs_to :profile

  validates :profile_id, presence: true
  validates :degree_id, presence: true

  accepts_nested_attributes_for :degree, :allow_destroy => true, :reject_if => :all_blank
end

