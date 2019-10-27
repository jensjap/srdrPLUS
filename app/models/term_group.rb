# == Schema Information
#
# Table name: term_groups
#
#  id   :integer          not null, primary key
#  name :string(255)
#

class TermGroup < ApplicationRecord
  has_many :term_groups_colors
end
