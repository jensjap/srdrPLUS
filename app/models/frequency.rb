class Frequency < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :message_types, dependent: :destroy, inverse_of: :frequency
end
