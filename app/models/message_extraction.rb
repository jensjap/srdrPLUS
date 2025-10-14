# == Schema Information
#
# Table name: message_extractions
#
#  id           :bigint           not null, primary key
#  message_id   :bigint           not null
#  extraction_id :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class MessageExtraction < ApplicationRecord
  belongs_to :message
  belongs_to :extraction

  validates :message_id, uniqueness: { scope: :extraction_id }
end
