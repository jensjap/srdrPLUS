class Degreeholdership < ApplicationRecord
  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  before_destroy :halp

  belongs_to :degree, inverse_of: :degreeholderships
  belongs_to :profile, inverse_of: :degreeholderships

  validates :profile_id, presence: true
  validates :degree_id, presence: true

  def paranoia_restore_attributes
    {
      deleted_at: nil,
      active: true
    }
  end

  def paranoia_destroy_attributes
    {
      deleted_at: current_time_from_proper_timezone,
      active: nil
    }
  end

  private

  def halp
  end
end

