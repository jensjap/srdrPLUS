class ScreeningOption < ApplicationRecord
    belongs_to :project
    belongs_to :label_type, optional: true
    belongs_to :screening_option_type
end
