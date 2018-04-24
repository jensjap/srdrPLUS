class ComparisonsMeasure < ApplicationRecord
    belongs_to :comparison
    belongs_to :measure, required: false

    has_one :measurement, dependent: :destroy

    accepts_nested_attributes_for :measurement, allow_destroy: true
end
