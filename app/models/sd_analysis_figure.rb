class SdAnalysisFigure < ApplicationRecord
  has_many_attached :pictures

  belongs_to :sd_figurable, polymorphic: true
end

