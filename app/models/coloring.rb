# == Schema Information
#
# Table name: colorings
#
#  id              :integer          not null, primary key
#  colorable_type  :string(255)
#  colorable_id    :bigint
#  color_choice_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Coloring < ApplicationRecord
  belongs_to :colorable, polymorphic: true
  belongs_to :color_choice
end
