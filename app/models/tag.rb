class Tag < ApplicationRecord
  include SharedQueryableMethods
  include SharedProcessTokenMethods
    has_many :taggings
end
