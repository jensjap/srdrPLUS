# == Schema Information
#
# Table name: frequencies
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Frequency < ApplicationRecord
  has_many :message_types, dependent: :destroy, inverse_of: :frequency
end
