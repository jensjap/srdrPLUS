# == Schema Information
#
# Table name: statusings
#
#  id              :bigint           not null, primary key
#  statusable_type :string(255)
#  statusable_id   :bigint
#  status_id       :bigint
#  deleted_at      :datetime
#  active          :boolean
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Statusing < ApplicationRecord
  belongs_to :statusable, polymorphic: true
  belongs_to :status, inverse_of: :statusings

  validates :statusable, :status, presence: true
end
