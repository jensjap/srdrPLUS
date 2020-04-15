class SdOutcome < ApplicationRecord
  belongs_to :sd_outcomeable, polymorphic: true
end
