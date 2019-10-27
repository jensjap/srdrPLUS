# == Schema Information
#
# Table name: terms
#
#  id   :integer          not null, primary key
#  name :string(255)
#

class Term < ApplicationRecord
  include SharedQueryableMethods
end
