# == Schema Information
#
# Table name: colors
#
#  id       :integer          not null, primary key
#  hex_code :string(255)
#  name     :string(255)
#

class Color < ApplicationRecord
  has_many :term_groups_colors
end
