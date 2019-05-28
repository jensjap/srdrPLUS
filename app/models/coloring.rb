class Coloring < ApplicationRecord
  belongs_to :colorable, polymorphic: true
  belongs_to :color_choice
end
