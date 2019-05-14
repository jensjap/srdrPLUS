# == Schema Information
#
# Table name: term_groups_colors
#
#  id            :integer          not null, primary key
#  term_group_id :integer
#  color_id      :integer
#

class TermGroupsColor < ApplicationRecord
  belongs_to :term_group
  belongs_to :color

  accepts_nested_attributes_for :term_group
end
