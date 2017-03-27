class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :organization
  belongs_to :title
  #accepts_nested_attributes_for :organization, reject_if: lambda { |attributes| attributes['name'].blank? }

  has_paper_trail

  acts_as_paranoid
end
