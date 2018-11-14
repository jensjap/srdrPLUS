class Reason < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :labels_reasons
end
