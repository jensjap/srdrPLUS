class Dispatch < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid
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
