class TermGroupsColor < ApplicationRecord
  belongs_to :term_group
  belongs_to :color

  accepts_nested_attributes_for :term_group
end
