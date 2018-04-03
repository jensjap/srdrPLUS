class Record < ApplicationRecord
  belongs_to :recordable, polymorphic: true
end
