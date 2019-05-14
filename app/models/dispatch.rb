# == Schema Information
#
# Table name: dispatches
#
#  id                :integer          not null, primary key
#  dispatchable_type :string(255)
#  dispatchable_id   :integer
#  user_id           :integer
#  deleted_at        :datetime
#  active            :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Dispatch < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :dispatchable, polymorphic: true
  belongs_to :user, inverse_of: :dispatches

  validates :dispatchable, :user, presence: true

  # Checks if this Dispatch is older than Dispatchable's frequency allows.
  def is_stale?
    frequency = dispatchable.frequency.name
    created_at < time_for_interval(frequency)
  end

  def time_for_interval(frequency)
    {
      "Daily": 1.day.ago,
      "Weekly": 7.days.ago,
      "Monthly": 1.month.ago,
      "Annually": 1.year.ago
    }[frequency.to_sym] || (raise 'UnknownFrequency')
  end
end
